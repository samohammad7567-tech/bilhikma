
Step-by-step plan to take this app from "builds on a laptop" to a reproducible,
signed, automatically built and distributed pipeline.

Written against the repo as it stands today. Every step says **why**, **what to
run**, and **what to commit**.

---

| Area | Current state | Gap |
|------|---------------|-----|
| Repo | GitLab: `gitlab.com/hawasly1/bilhikma/bilhikma_mobile` — but the local git dir is named `.gittt/`, so this working copy is **not** a live git checkout | Restore `.git/` before any CI work |
| Platforms | Android only (`android/`). No `ios/` folder | iOS is a later phase |
| Flutter | 3.44.5 stable (`f94f4fc76b`), Dart SDK `^3.12.2` | Version not pinned anywhere machine-readable |
| Android toolchain | AGP 8.11.1, Gradle 8.14, Kotlin 2.3.20, JDK 17 | Fine — CI must match exactly |
| App id | `tech.bilhikma.app` (single id, no flavors) | No dev/staging/prod separation |
| Signing | `release { signingConfig = signingConfigs.getByName("debug") }` | **Release builds are debug-signed — cannot be published** |
| Config | `ApiEndpoints.baseUrl = 'https://bilhikma.tech/api'` hardcoded | No per-environment base URL |
| Firebase | `firebase_core` + `firebase_messaging`, `android/app/google-services.json` committed, gradle applies the plugin conditionally | Config file should be injected, not tracked |
| Versioning | `version: 1.0.0+2` in `pubspec.yaml`, bumped by hand | Build number must come from CI |
| Tests | No `test/` directory | Nothing for CI to run beyond analyze |
| CI/CD | None | Everything below |
| Release artifacts | Local `flutter build apk` only | No AAB, no store upload, no QA channel |

**Order of work:** sections 1 → 5 are the critical path (a signed, CI-built
artifact). 6 → 9 are hardening. 10 is iOS, whenever it is needed.

---

Nothing else is reproducible until the repository is clean.

```bash
mv .gittt .git
git status
git remote -v   # expect: origin  https://gitlab.com/hawasly1/bilhikma/bilhikma_mobile.git
```

If the rename was deliberate (to hide the repo from a tool), keep a proper
checkout elsewhere and treat this folder as a scratch copy — CI needs a real
repository.

Present in the working directory, must never reach a commit:

```
build/                             # already gitignored — verify it is not tracked
.dart_tool/                        # already gitignored
لم يتم تأكيده 365410.crdownload    # 46 MB stray download — delete
*.pdf                              # first_task.pdf, task2.pdf, fix_ui.pdf, rename.pdf
```

```bash
git rm -r --cached build .dart_tool 2>/dev/null
rm -f "لم يتم تأكيده 365410.crdownload"
```

Move the task/spec markdown + PDFs into `docs/` so the root holds only project
files. Confirm whether `screens/` is real source or screenshots; if the latter,
it belongs in `docs/` too.

Append:

```gitignore
android/key.properties
**/*.keystore
**/*.jks
*.p12
*.p8
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
**/service-account*.json
fastlane/*.json
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
.env
.env.*
!.env.example
```

`google-services.json` is currently tracked. It is not a hard credential, but it
identifies the Firebase project and should be injected by CI instead:

```bash
git rm --cached android/app/google-services.json
```

The gradle file already handles its absence gracefully
(`if (file("google-services.json").exists())`), so local builds without Firebase
still work — good design, keep it.

Create `.fvmrc` (or a plain `FLUTTER_VERSION` file CI reads):

```json
{ "flutter": "3.44.5" }
```

Add to `README.md` (currently empty): required Flutter 3.44.5 stable, JDK 17,
Android SDK, and the run commands from Appendix B.

```
main         → production, protected, tagged releases only
develop      → integration, auto-deploys to Firebase App Distribution
feature/*    → branched from develop, MR back into develop
hotfix/*     → branched from main, MR into main + develop
```

Protect `main` and `develop` in GitLab: no direct pushes, MR + green pipeline
required.

---

`ApiEndpoints.baseUrl` is a compile-time constant pointing at production. Make it
injectable so dev/staging builds hit their own backend.

`lib/core/constants/api_endpoints.dart`:

```dart
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bilhikma.tech/api',
  );

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static bool get isProd => environment == 'prod';
}
```

`String.fromEnvironment` must stay `const` — reading it at runtime changes how
the release build tree-shakes.

`config/dev.json`:

```json
{ "APP_ENV": "dev", "API_BASE_URL": "https://dev.bilhikma.tech/api" }
```

`config/staging.json` and `config/prod.json` likewise. Commit these — they hold
base URLs only, no secrets. Build with:

```bash
flutter build apk --release --dart-define-from-file=config/prod.json
```

`.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "bilhikma dev",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "args": ["--flavor", "dev", "--dart-define-from-file", "config/dev.json"]
    },
    {
      "name": "bilhikma prod",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release",
      "args": ["--flavor", "prod", "--dart-define-from-file", "config/prod.json"]
    }
  ]
}
```

---

Three flavors, three application ids, so dev/staging/prod install side by side on
one device and Firebase registers them separately.

Add inside `android { }`:

```kotlin
flavorDimensions += "env"

productFlavors {
    create("dev") {
        dimension = "env"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "بالحكمة Dev")
    }
    create("staging") {
        dimension = "env"
        applicationIdSuffix = ".staging"
        versionNameSuffix = "-staging"
        resValue("string", "app_name", "بالحكمة Staging")
    }
    create("prod") {
        dimension = "env"
        resValue("string", "app_name", "بالحكمة")
    }
}
```

`AndroidManifest.xml` currently hardcodes `android:label="بالحكمة"`, so all three
flavors would show the same name. Change it to the resource:

```xml
<application
    android:label="@string/app_name"
    ...>
```

Each flavor is a distinct `applicationId`, so each needs its own Firebase Android
app and its own config file:

```
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/prod/google-services.json
```

The existing guard in `build.gradle.kts` checks `android/app/google-services.json`.
Either apply the plugin unconditionally once the per-flavor files exist, or keep
the guard and drop the prod copy at the app root.

```bash
flutter build apk --debug --flavor dev  --dart-define-from-file=config/dev.json
flutter build apk --debug --flavor prod --dart-define-from-file=config/prod.json
```

Both must install on the same device simultaneously.

---

`release` currently reuses the debug signing config. A debug-signed AAB is
rejected by Play.

```bash
keytool -genkey -v -keystore bilhikma-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Store the `.jks` and its passwords in the team password manager. Losing it means
losing the ability to update the app (recoverable only via a Play upload-key
reset).

```properties
storeFile=../../bilhikma-upload.jks
storePassword=***
keyAlias=upload
keyPassword=***
```

Above `android { }`:

```kotlin
val keystoreProperties = java.util.Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
```

Inside `android { }`, replacing the current `buildTypes` block:

```kotlin
signingConfigs {
    create("release") {
        if (keystoreProperties.containsKey("storeFile")) {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
}

buildTypes {
    release {
        signingConfig = if (keystoreProperties.containsKey("storeFile"))
            signingConfigs.getByName("release")
        else
            signingConfigs.getByName("debug")   // local dev fallback only
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

R8 needs keep rules for the heavier plugins in this app:

```proguard
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.syncfusion.** { *; }
-keep class com.ryanheise.** { *; }        # just_audio / audio_service
-dontwarn javax.annotation.**
```

Smoke-test a minified release build before trusting it — PDF viewing (Syncfusion),
background audio (just_audio / audio_service) and FCM are the three things R8 is
most likely to break here. If minification causes trouble under deadline, ship
with `isMinifyEnabled = false` and fix it in a follow-up.

CI has no `key.properties`. Store the keystore base64-encoded as a masked
variable and rebuild both files in the pipeline (section 5):

```bash
base64 -w0 bilhikma-upload.jks > keystore.b64   # paste into ANDROID_KEYSTORE_B64
```

---

The remote is GitLab, so `.gitlab-ci.yml` is the primary pipeline. A GitHub
Actions equivalent is in Appendix A.

Settings → CI/CD → Variables. Mark every one **Masked**; mark signing and
service-account variables **Protected** so only `main`/`develop` can read them.

| Variable | Type | Contents |
|----------|------|----------|
| `ANDROID_KEYSTORE_B64` | Var | base64 of `bilhikma-upload.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Var | store password |
| `ANDROID_KEY_ALIAS` | Var | `upload` |
| `ANDROID_KEY_PASSWORD` | Var | key password |
| `GOOGLE_SERVICES_JSON_PROD` | File | prod `google-services.json` |
| `GOOGLE_SERVICES_JSON_DEV` | File | dev/staging `google-services.json` |
| `PLAY_SERVICE_ACCOUNT_JSON` | File | Play Console service-account key |
| `FIREBASE_APP_ID_ANDROID` | Var | `1:xxx:android:yyy` |
| `FIREBASE_TOKEN` | Var | App Distribution auth |

```yaml
image: ghcr.io/cirruslabs/flutter:3.44.5

variables:
  GRADLE_USER_HOME: "$CI_PROJECT_DIR/.gradle"

cache:
  key: "$CI_COMMIT_REF_SLUG"
  paths:
    - .pub-cache/
    - .gradle/

stages: [verify, build, distribute, release]

.flutter_setup: &flutter_setup
  before_script:
    - flutter --version
    - flutter pub get

analyze:
  stage: verify
  <<: *flutter_setup
  script:
    - dart format --output=none --set-exit-if-changed lib/
    - flutter analyze --fatal-infos
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH

test:
  stage: verify
  <<: *flutter_setup
  script:
    - flutter test --coverage
  artifacts:
    paths: [coverage/]
    when: always
  allow_failure: true   # flip to false once test/ exists (section 7)

.android_signing: &android_signing
  - echo "$ANDROID_KEYSTORE_B64" | base64 -d > "$CI_PROJECT_DIR/upload.jks"
  - |
    cat > android/key.properties <<PROPS
    storeFile=$CI_PROJECT_DIR/upload.jks
    storePassword=$ANDROID_KEYSTORE_PASSWORD
    keyAlias=$ANDROID_KEY_ALIAS
    keyPassword=$ANDROID_KEY_PASSWORD
    PROPS

build:staging:
  stage: build
  <<: *flutter_setup
  script:
    - *android_signing
    - cp "$GOOGLE_SERVICES_JSON_DEV" android/app/google-services.json
    - flutter build apk --release
      --flavor staging
      --dart-define-from-file=config/staging.json
      --build-number=$CI_PIPELINE_IID
  artifacts:
    paths: [build/app/outputs/flutter-apk/*.apk]
    expire_in: 2 weeks
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

build:prod:
  stage: build
  <<: *flutter_setup
  script:
    - *android_signing
    - cp "$GOOGLE_SERVICES_JSON_PROD" android/app/google-services.json
    - flutter build appbundle --release
      --flavor prod
      --dart-define-from-file=config/prod.json
      --build-number=$CI_PIPELINE_IID
      --obfuscate --split-debug-info=build/symbols
  artifacts:
    paths:
      - build/app/outputs/bundle/prodRelease/*.aab
      - build/symbols/
    expire_in: 1 year
  rules:
    - if: $CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/

distribute:qa:
  stage: distribute
  image: node:20
  needs: ["build:staging"]
  before_script:
    - npm i -g firebase-tools
  script:
    - firebase appdistribution:distribute
      build/app/outputs/flutter-apk/app-staging-release.apk
      --app "$FIREBASE_APP_ID_ANDROID"
      --groups "qa,internal"
      --release-notes "$CI_COMMIT_TITLE ($CI_COMMIT_SHORT_SHA)"
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

release:play:
  stage: release
  needs: ["build:prod"]
  script:
    - cd android && bundle exec fastlane internal
  rules:
    - if: $CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/
      when: manual        # a human approves every production upload
```

`pubspec.yaml` keeps the **version name** (`1.0.0`); the **build number** always
comes from `--build-number=$CI_PIPELINE_IID`, so it is monotonic and never
collides on Play. Stop hand-editing the `+2`.

Release flow: bump `version: 1.1.0+0` → merge to `main` → tag `v1.1.0` → the
tagged pipeline builds and (after manual approval) uploads.

---

1. Create the app in Play Console with package `tech.bilhikma.app`.
2. Upload the first AAB **by hand** — the API cannot create the first release.
3. Google Cloud → service account → grant it "Release manager" in Play Console →
   download the JSON key → store as `PLAY_SERVICE_ACCOUNT_JSON` in GitLab.

`android/Gemfile`:

```ruby
source "https://rubygems.org"
gem "fastlane"
```

`android/fastlane/Appfile`:

```ruby
json_key_file(ENV["PLAY_SERVICE_ACCOUNT_JSON"])
package_name("tech.bilhikma.app")
```

`android/fastlane/Fastfile`:

```ruby
default_platform(:android)

platform :android do
  desc "Upload the prod AAB to the internal testing track"
  lane :internal do
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/prodRelease/app-prod-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      release_status: "draft"
    )
  end

  desc "Promote the internal build to production (staged 20%)"
  lane :promote do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production",
      rollout: "0.2",
      skip_upload_aab: true,
      skip_upload_metadata: true
    )
  end
end
```

Validate credentials before the first CI run:

```bash
cd android && bundle exec fastlane run validate_play_store_json_key
```

---

There is no `test/` directory, so CI has nothing to protect the app with today.
Minimum viable suite, in priority order:

1. **Unit — models**: `fromJson`/`toJson` round-trips for the API models
   (`lib/core/models`, feature `data/models`). Cheapest bugs to catch.
2. **Unit — cubits**: `bloc_test` over the feature cubits (auth, lessons, home).
   Fake the data sources, assert emitted state sequences.
3. **Unit — helpers**: error mapping, `AppRegex` validators, pagination,
   `playback_uri_resolver`.
4. **Widget**: the small dumb widgets, catching localization-key and overflow
   regressions.
5. **Integration** (later): login → home → open a lesson via `integration_test`,
   run on Firebase Test Lab.

Add dev dependencies:

```yaml
dev_dependencies:
  bloc_test: ^10.0.0
  mocktail: ^1.0.4
```

Once the first tests land, remove `allow_failure: true` from the `test` job and
set a coverage floor.

Also enforce in `analysis_options.yaml` the rules this architecture depends on:
`avoid_print`, `prefer_relative_imports` (no `package:bilhikma/...` inside
`lib/`), `use_build_context_synchronously`.

---

1. **Crashlytics** — add `firebase_crashlytics` and hook it up in `main.dart`:

   ```dart
   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
   PlatformDispatcher.instance.onError = (error, stack) {
     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
     return true;
   };
   ```

2. **Symbols** — prod builds use `--obfuscate --split-debug-info`, so stack
   traces are unreadable without the symbols archived by `build:prod`. Keep those
   artifacts (already a year) and upload native symbols to Crashlytics in the
   same job.

3. **Analytics** — `firebase_analytics` for funnel events (login, lesson start,
   test submit).

4. **Alerting** — Crashlytics velocity alerts routed to the team channel.

---

- Never echo secrets: masked variables, and `set +x` around the signing steps.
- The app already uses `flutter_secure_storage` and `screen_protector` — keep
  release builds obfuscated so token handling is not trivially readable.
- Add a `verify` job running `flutter pub outdated`, and optionally `osv-scanner`
  against `pubspec.lock` for vulnerable transitive packages.
- Rotate the Play service-account key yearly; keep the upload keystore offline
  and backed up in two places.
- Restrict Protected variables to protected branches, so a fork or MR pipeline
  can never read the keystore.

---

There is no `ios/` folder yet. When iOS starts:

1. `flutter create --platforms=ios .`
2. Flip `ios: true` in both `flutter_launcher_icons` and `flutter_native_splash`
   in `pubspec.yaml` (both are currently `false`, with comments explaining why),
   then re-run the generators.
3. Xcode schemes `dev` / `staging` / `prod` matching the Android flavors, bundle
   ids `tech.bilhikma.app`, `.dev`, `.staging`.
4. `fastlane match` (git-backed certificate repo) for signing — never manual
   provisioning profiles in CI.
5. A macOS runner (GitLab SaaS macOS runners or a self-hosted Mac mini);
   `build:ios` + `upload_to_testflight` lanes mirroring section 6.
6. Per-flavor `GoogleService-Info.plist`, injected the same way as
   `google-services.json`.

---

- [ ] `.gittt` → `.git`, verify remote, delete stray files, move docs to `docs/`
- [ ] `.gitignore` extended; `google-services.json` untracked
- [ ] Toolchain pinned (`.fvmrc`, README prerequisites)
- [ ] `main` / `develop` protected; MR + green pipeline required
- [ ] `ApiEndpoints` reads `String.fromEnvironment`; `config/*.json` committed
- [ ] Flavors `dev` / `staging` / `prod`; manifest label → `@string/app_name`
- [ ] Upload keystore created, backed up; `key.properties` gitignored
- [ ] Release `signingConfig` fixed; R8 + ProGuard rules smoke-tested
- [ ] GitLab CI/CD variables added (masked + protected)
- [ ] `.gitlab-ci.yml` green: analyze → test → build → distribute
- [ ] Firebase App Distribution delivering `develop` builds to QA
- [ ] Play Console app created; first AAB uploaded manually
- [ ] Fastlane `internal` lane uploading tagged builds
- [ ] First tests landed; `allow_failure` removed from the test job
- [ ] Crashlytics + symbol upload live
- [ ] iOS phase scheduled (section 10)

---

If the project mirrors to GitHub, `.github/workflows/android.yml`:

```yaml
name: Android CI

on:
  pull_request:
  push:
    branches: [develop]
    tags: ['v*']

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.44.5', channel: stable, cache: true }
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed lib/
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage

  build:
    needs: verify
    if: github.ref == 'refs/heads/develop' || startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.44.5', channel: stable, cache: true }
      - name: Restore signing config
        env:
          KEYSTORE_B64: ${{ secrets.ANDROID_KEYSTORE_B64 }}
          STORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          echo "$KEYSTORE_B64" | base64 -d > "$RUNNER_TEMP/upload.jks"
          {
            echo "storeFile=$RUNNER_TEMP/upload.jks"
            echo "storePassword=$STORE_PASSWORD"
            echo "keyAlias=$KEY_ALIAS"
            echo "keyPassword=$KEY_PASSWORD"
          } > android/key.properties
      - name: Restore Firebase config
        env:
          GS_JSON: ${{ secrets.GOOGLE_SERVICES_JSON_PROD }}
        run: printf '%s' "$GS_JSON" > android/app/google-services.json
      - run: flutter pub get
      - run: |
          flutter build appbundle --release --flavor prod \
            --dart-define-from-file=config/prod.json \
            --build-number=${{ github.run_number }} \
            --obfuscate --split-debug-info=build/symbols
      - uses: actions/upload-artifact@v4
        with:
          name: bilhikma-aab
          path: build/app/outputs/bundle/prodRelease/*.aab
```

Secrets live in Settings → Secrets and variables → Actions, using the same names
as section 5.1.

---

```bash
flutter run --flavor dev --dart-define-from-file=config/dev.json
flutter build apk --release --flavor staging \
  --dart-define-from-file=config/staging.json
flutter build appbundle --release --flavor prod \
  --dart-define-from-file=config/prod.json \
  --obfuscate --split-debug-info=build/symbols
dart format --output=none --set-exit-if-changed lib/
flutter analyze --fatal-infos
flutter test --coverage
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
