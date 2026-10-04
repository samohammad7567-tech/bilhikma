# DevOps Test Report — BilHikma Mobile

**Date:** 2026-09-18
**Branch:** `feature/pdf-file-updates-phone-number` @ `7c85d5b`
**Toolchain under test:** Flutter 3.47.4 stable (`9584c6713b`) · Dart 3.13.3 · AGP 8.11.1 · Gradle 8.14.0 · Kotlin 2.3.20 · JDK 17
**Host:** Windows 10 Enterprise LTSC 2021, system locale `ar`

This is a **results** document — every line below is the outcome of a command that
was actually run against this working copy. The companion file `devops.md` is the
*plan*; this one records what the pipeline does today.

---

## 1. Scoreboard

| # | Test | Command | Result |
|---|------|---------|--------|
| 1 | Static analysis | `flutter analyze` | ⚠️ **PASS w/ 8 issues** (0 errors) |
| 2 | Format gate | `dart format --set-exit-if-changed lib` | ✅ **PASS** (534 files, 0 changed) |
| 3 | Unit/widget tests | `flutter test` | ❌ **NO TESTS** — `test/` does not exist |
| 4 | Release APK build | `flutter build apk --release` | ✅ **PASS** — 74.4 MB in 113.5 s |
| 5 | Release AAB build | `flutter build appbundle --release` | ❌ **FAIL** — bundletool locale defect |
| 5b | Release AAB, locale forced | same + `-Duser.language=en` | ✅ **PASS** — 72.4 MB |
| 6 | Signing verification | `apksigner verify --print-certs` | ❌ **FAIL** — signed `CN=Android Debug` |
| 7 | Merged manifest audit | AGP `processReleaseManifest` output | ⚠️ **PARTIAL** — audio service missing |
| 8 | Dependency freshness | `flutter pub outdated` | ⚠️ 9 direct outdated, 3 behind a major |
| 9 | Secret scan | `grep` over `lib/` + `git ls-files` | ⚠️ no Dart secrets; FCM config committed |
| 10 | Repo hygiene | `git ls-files`, `du` | ❌ **FAIL** — 45 MB binary + foreign `.git` tracked |
| 11 | CI/CD presence | filesystem probe | ❌ **NONE** — no CI, no Fastlane, no flavors |
| 12 | Localization parity | `ar.json` vs `en.json` | ✅ **PASS** — 255 / 255 keys, no gaps |
| 13 | Architecture rules | `find` / `grep` vs project conventions | ⚠️ 25 files > 150 lines, no `LangKeys` |

**Verdict: the project cannot ship to Google Play today.** Two independent
blockers (debug signing, AAB build failure) sit on the release path, and there is
no automation of any kind behind them.

---

## 2. Blockers

### B1 — Release builds are signed with the Android debug key

`android/app/build.gradle.kts:26`

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Verified against the artifact this run produced:

```
$ apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
V2 Signer: certificate DN: C=US, O=Android, CN=Android Debug
V2 Signer: certificate SHA-256 digest: 779f8f90e9a38a9a7635f2ea0f9ff2337701243153625a8cbfcd40201c3bf09f
V2 Signer: certificate SHA-1 digest:   9ffae0b77bc08fe2555925cf8ab256dbcfd83621
```

The key is `~/.android/debug.keystore` on this one laptop. Consequences:

- Play Console rejects debug-signed uploads outright.
- The signing identity is machine-local, so no two developers — and no CI runner —
  can produce a compatible update.
- Only a V2 signature is present; no V1. Fine for `minSdk 24`, but worth knowing.

**Fix:** create a real upload keystore, load it from `key.properties`
(gitignored) or CI secrets, and add a `signingConfigs.release` block. Never
commit the `.jks`.

### B2 — `flutter build appbundle` fails on this machine

```
$ flutter build appbundle --release
Execution failed for task ':app:packageReleaseBundle'.
> A failure occurred while executing PackageBundleTask$BundleToolWorkAction
   > Invalid dex file indices, expecting file 'classes٢.dex' but found 'classes2.dex'.
BUILD FAILED in 10s
```

Note the digit: `classes٢.dex` uses **U+0662 ARABIC-INDIC DIGIT TWO**. bundletool
formats the dex index through the JVM's default locale, and the host's system
locale is Arabic, so `2` renders as `٢` and the name-match against the real
`classes2.dex` fails. APK builds are unaffected — only bundling, which is exactly
the artifact Play requires.

**Confirmed by isolation.** Appending a locale override to
`android/gradle.properties` and re-running:

```properties
org.gradle.jvmargs=-Xmx3G -XX:MaxMetaspaceSize=1G -XX:ReservedCodeCacheSize=256m \
  -XX:+HeapDumpOnOutOfMemoryError -Duser.language=en -Duser.country=US
```

```
√ Built build\app\outputs\bundle\release\app-release.aab (72.4MB)
```

The override was **reverted after the test** — `android/gradle.properties` is
back to its committed contents and the working tree is unchanged. Applying it
permanently is the recommended fix: it costs nothing, and it also makes local
builds match a `LANG=en_US` CI runner.

---

## 3. High severity

### H1 — Background audio is wired in Dart but absent from the Android manifest

`lib/core/services/audioplayerservice/audio_player_service.dart:23` calls
`JustAudioBackground.init(...)`, and `AudioPlayerHandler` extends
`BaseAudioHandler`. The merged release manifest contains **none** of what
`just_audio_background` / `audio_service` require:

```
$ grep -ci foreground .../merged_manifests/release/processReleaseManifest/AndroidManifest.xml
0
```

Missing, all of it:

- `android.permission.FOREGROUND_SERVICE` and
  `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK`
- `<service android:name="com.ryanheise.audioservice.AudioService"
  android:foregroundServiceType="mediaPlayback">` with the
  `android.media.browse.MediaBrowserService` intent filter
- `<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver">`

And `android/app/src/main/kotlin/.../MainActivity.kt` declares
`class MainActivity : FlutterActivity()` where the plugin requires
`AudioServiceActivity`.

Audio playback while the app is backgrounded, the media notification, and
lock-screen controls cannot work as shipped. This is a functional defect that a
release-build smoke test would have caught — there are none.

### H2 — The auth bearer token is stored in plaintext SharedPreferences

`lib/core/services/dio_service.dart:11` and
`lib/core/interceptors/auth_interceptor.dart:106`:

```dart
final Object? token = CacheUtil.get(key: 'token');   // SharedPreferences
```

`CacheUtil` is a thin `SharedPreferences` wrapper — the token lands in
`shared_prefs/*.xml` in cleartext. The project already depends on
`flutter_secure_storage` and already uses it correctly for the device UUID
(`device_service.dart:11`) and the session fingerprint
(`device_session_service.dart:17`). The access and refresh tokens are the one
thing that did not get the same treatment.

### H3 — Device UUID is printed to logcat on every launch, in release builds

`lib/main.dart:29`:

```dart
print(DeviceService.metadata);
```

`DeviceService.metadata` carries `device_uuid` — the identifier that
`DeviceSessionService` uses to bind a session to a device. Dart `print` is **not**
stripped from Flutter release builds; it goes to logcat. Anything holding
`READ_LOGS`, or anyone with adb access, can read the value the device-binding
security model depends on. Two more `print` calls sit in
`main_shell_view.dart:24` and `search_results.dart:43`.

### H4 — No CI/CD, no flavors, no environment separation

Probed and absent: `.github/`, `.gitlab-ci.yml`, `fastlane/`, `Makefile`,
`productFlavors` in `build.gradle.kts`.

- One `applicationId` — `tech.bilhikma.app` — for every environment. A QA build
  cannot be installed next to production.
- `ApiEndpoints.baseUrl` is a `const String` hardcoded to
  `https://bilhikma.tech/api` (`lib/core/constants/api_endpoints.dart:4`). No
  `--dart-define`, no staging target. Pointing a build at staging means editing
  source.
- `version: 1.0.0+3` in `pubspec.yaml` is bumped by hand — it was `+2` when
  `devops.md` was written.
- Every release is a `flutter build` on one developer's laptop, which is also the
  only machine holding the (debug) signing key. Zero reproducibility.

---

## 4. Medium severity

### M1 — Repository is polluted with 45 MB+ of artifacts that should never have been committed

```
$ git ls-files | wc -l
1603
```

Tracked, and shouldn't be:

| Path | Size | Why it's a problem |
|------|------|--------------------|
| `لم يتم تأكيده 365410.crdownload` | **45 MB** | Aborted Chrome download. Permanently in history. |
| `.gittt for gitlab/**` | **931 files, 7 MB** | A complete `.git` directory of *another* repo, committed as ordinary files |
| `*.pdf` (5 files) | 852 KB | Task specs |
| `Bilhikma_Platform.json` | 616 KB | API spec dump |
| `screens/log_in_with_lag_change.png` | — | Screenshot |

The `.gittt for gitlab/` payload is the worrying one. Its `config` exposes a
second origin:

```ini
[remote "origin"]
    url = https://gitlab.com/hawasly1/bilhikma/bilhikma_mobile.git
```

It also carries that repository's full object database and reflogs. Anyone with
read access to the GitHub remote can reconstruct branches from the GitLab
project. Treat this as a disclosure issue, not just untidiness.

Every clone pays the 45 MB. Removing the files in a new commit does **not**
shrink history — that needs `git filter-repo` plus a force-push, coordinated
with everyone holding a clone.

`.gitignore` should gain: `*.crdownload`, `*.pdf`, `.gittt*/`, `screens/`.

### M2 — `google-services.json` is committed

`android/app/google-services.json` is tracked. It is not a private key, but it
pins the Firebase project into source control and makes per-environment Firebase
projects impossible without editing the file. Inject it from a CI secret and
gitignore it — `android/app/build.gradle.kts` already guards on
`if (file("google-services.json").exists())`, so the build tolerates its absence.

### M3 — Dio has no timeouts

`lib/core/services/dio_service.dart:16` builds `BaseOptions` with a base URL and
headers only. No `connectTimeout`, no `receiveTimeout`, no `sendTimeout`. On a
stalled connection the request hangs until the OS gives up — the user sees a
spinner that never resolves. Set all three (10 s / 30 s / 30 s is a reasonable
starting point).

### M4 — Artifact size

| Artifact | Size |
|----------|------|
| `app-release.apk` (fat, 3 ABIs) | **74.4 MB** |
| `app-release.aab` | **72.4 MB** |
| per-ABI split APKs | 27–31 MB each |

Dominated by native code:

```
13.8 MB  lib/armeabi-v7a/libapp.so
13.1 MB  lib/x86_64/libflutter.so
12.6 MB  lib/x86_64/libapp.so
12.3 MB  lib/arm64-v8a/libapp.so
11.7 MB  lib/arm64-v8a/libflutter.so
 8.6 MB  lib/armeabi-v7a/libflutter.so
 4.1 MB  classes.dex
```

`x86_64` accounts for ~25 MB and serves emulators only. Ship the AAB (Play splits
per device) and use `--target-platform android-arm,android-arm64` for any direct
APK distribution. Flutter assets are only 2 MB, so there is little to win there —
though `logo_ornament.png` at 427 KB and two ~294 KB SVGs are worth a pass.

### M5 — Toolchain is unpinned and two deprecation warnings deep

No `.fvmrc`, no `.tool-versions`, no `flutter` field in `pubspec.yaml`. CI would
have to guess the SDK. Both release builds also warned:

```
Warning: Flutter support for your project's Gradle version (8.14.0) will soon be
dropped. Please upgrade to at least 9.1.0 soon.
Warning: Flutter support for your project's Android Gradle Plugin version (8.11.1)
will soon be dropped. Please upgrade to at least 9.0.1 soon.
```

Pin `Flutter 3.47.4` explicitly, then schedule the Gradle/AGP bump before the
next SDK upgrade forces it.

---

## 5. Low severity

### L1 — `flutter analyze`: 8 issues, 0 errors (113.4 s)

```
warning - The value of the field '_boundDeviceKey' isn't used  — core/constants/cache_keys.dart:14
warning - The value of the field '_boundTokenKey' isn't used   — core/constants/cache_keys.dart:15
warning - Unused import: '../network/json_reader.dart'          — core/enums/lesson_category_enum.dart:1
warning - 'LockCachingAudioSource' is experimental              — core/services/audioplayerservice/audio_player_handler.dart:258
warning - Unused import: 'settings_glyph_tile.dart'             — features/settings/presentation/widgets/settings_choice_card.dart:5
   info - Don't invoke 'print' in production code               — features/main_shell/presentation/widgets/main_shell_view.dart:24
   info - Don't invoke 'print' in production code               — features/search/presentation/widgets/search_results.dart:43
   info - Don't invoke 'print' in production code               — main.dart:29   ← see H3
```

`analysis_options.yaml` has an **empty** `linter.rules:` block — the project runs
`flutter_lints` defaults and nothing more.

### L2 — No `LangKeys`; 145 raw translation strings

`lib/core/localization/lang_keys.dart` does not exist. 145 call sites use raw
literals — `'logout'.tr()`, `'coming_soon'.tr()`, `'retry'.tr()` — so a renamed
key fails silently at runtime instead of at compile time. Key parity itself is
clean (255 = 255, no orphans in either direction), which is the part that usually
rots.

### L3 — 25 files exceed the 150-line ceiling

Worst offenders:

```
399  features/lesson_detail/presentation/cubit/lesson_detail_cubit.dart   (cubits are exempt)
355  features/gallery/presentation/screens/gallery_viewer_screen.dart     ← screen, target 30–70
319  features/lesson_test/presentation/cubit/lesson_test_cubit.dart       (cubits are exempt)
297  core/services/audioplayerservice/audio_player_handler.dart
283  core/services/videoplayerservice/widgets/video_controls_overlay.dart
281  core/routing/app_router.dart
271  features/educational_pathways/data/data_source/educational_pathways_data_source.dart
```

`gallery_viewer_screen.dart` at 355 lines is the clearest violation — screens are
supposed to create a Cubit and render a body. No forbidden `domain/`, `entities/`,
`use_cases/`, or `repo_impl/` directories exist, so the layering itself is sound.

### L4 — 7 absolute `package:bilhikma/...` imports inside `lib/`

Convention is relative imports within `lib/`. Minor, mechanical.

### L5 — Placeholder shipped in release

`lib/features/settings/data/data_source/settings_data_source.dart:12`:

```dart
static const String appShareLink = 'https://TODO_SET_SHARE_LINK';
```

The only TODO in the codebase, and it is user-facing — the share sheet hands out
a dead link.

---

## 6. What passed

Worth stating, because most of it is non-trivial:

- **Release APK builds clean** — exit 0 in 113.5 s, no errors.
- **Zero analyzer errors** across 534 files / 31,656 lines.
- **Formatting is already CI-clean** — `dart format --set-exit-if-changed` exits 0.
  That gate can be turned on today at no cost.
- **`minSdk 24` / `targetSdk 36`** — meets the current Play target-API requirement.
- **Permissions are minimal and justified.** The merged manifest requests only
  `INTERNET`, `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`,
  `DETECT_SCREEN_CAPTURE`, plus `VIBRATE`/`WAKE_LOCK`/`c2dm.RECEIVE` from FCM.
  Each app-declared one carries a comment explaining why.
- **No hardcoded credentials in Dart.** The secret scan over `lib/` returned only
  endpoint path constants (`/reset-password`, `/user/profile/password`, …) — no
  keys, no tokens, no passwords.
- **`pubspec.lock` is committed** — dependency resolution is reproducible.
- **Localization is complete** — 255 keys, ar/en in exact parity.
- **Clean layering** — no forbidden `domain/` / `use_cases/` / `repo_impl/` dirs.
- **Secure storage is used correctly** where it is used — device UUID and session
  fingerprint both go through `FlutterSecureStorage` (H2 is the gap, not the rule).

---

## 7. Dependency status

`flutter pub outdated` — 55 upgradable packages locked to older versions,
6 constrained below a resolvable version.

**Direct dependencies behind a major version** (needs a `pubspec.yaml` edit and
a migration pass):

| Package | Current | Latest |
|---------|---------|--------|
| `cached_network_image` | 3.4.1 | **4.0.0** |
| `flutter_secure_storage` | 10.3.1 | **11.2.0** |
| `youtube_player_flutter` | 9.1.3 | **10.0.1** |

**Direct dependencies with a safe in-range bump** (`flutter pub upgrade`):

| Package | Current | Upgradable |
|---------|---------|------------|
| `dio` | 5.11.0 | 5.11.1 |
| `firebase_core` | 4.13.0 | 4.15.0 |
| `firebase_messaging` | 16.5.0 | 16.7.0 |
| `flutter_local_notifications` | 22.3.0 | 22.3.1 |
| `syncfusion_flutter_pdf` | 34.2.3 | 34.2.8 |
| `syncfusion_flutter_pdfviewer` | 34.2.3 | 34.2.8 |

`dev_dependencies`: all up to date.

---

## 8. Recommended order of work

**Unblock the release path** — nothing else matters until an installable,
publishable artifact exists.

1. **B2** — add `-Duser.language=en -Duser.country=US` to `org.gradle.jvmargs`.
   One line, unblocks AAB builds. *(Verified working during this test.)*
2. **B1** — generate an upload keystore, wire `key.properties` +
   `signingConfigs.release`, gitignore the `.jks`.
3. **H3** — delete `print(DeviceService.metadata)` and the two other `print`
   calls. One line each, closes a real leak.

**Make it reproducible**

4. **M1** — `git rm` the `.crdownload`, `.gittt for gitlab/`, PDFs, and
   `screens/`; extend `.gitignore`; plan the history rewrite separately.
5. **H4** — CI (GitHub Actions) running `analyze` → `format --set-exit-if-changed`
   → `build appbundle`, with the keystore and `google-services.json` as secrets
   and the build number from the run number.
6. **M5** — pin Flutter 3.47.4 so CI and laptops agree.

**Correctness and hardening**

7. **H1** — add the `audio_service` manifest entries and switch `MainActivity`
   to `AudioServiceActivity`, then smoke-test background playback on a device.
8. **H2** — move the access/refresh token to `FlutterSecureStorage`.
9. **M3** — set Dio timeouts.
10. **M2** — inject `google-services.json` from CI instead of tracking it.
11. **H4 (flavors)** — `dev`/`staging`/`prod` product flavors with distinct
    `applicationId` suffixes; move `baseUrl` behind `--dart-define`.
12. **Test suite** — there is currently nothing for CI to run. Start with the
    pieces that carry real logic: `ErrorMapper`, the `AuthInterceptor` refresh
    flow, `ApiEnvelope` / `PaginatedResult` parsing, `DeviceSessionService`
    binding.
13. **M4** — drop `x86_64` from distributed APKs; ship the AAB.
14. **L1–L5** — analyzer cleanup, `LangKeys`, file-size splits, relative imports,
    and the `TODO_SET_SHARE_LINK` placeholder.

---

## Appendix — commands run

```bash
flutter --version
flutter analyze                                        # 8 issues, 0 errors, 113.4s
dart format --output=none --set-exit-if-changed lib    # 534 files, 0 changed
flutter test                                           # Test directory "test" not found
flutter build apk --release                            # exit 0, 74.4MB
flutter build appbundle --release                      # exit 1, bundletool dex-index failure
flutter build appbundle --release                      # exit 0, 72.4MB (locale forced, then reverted)
flutter pub outdated
apksigner verify --print-certs .../app-release.apk
unzip -l .../app-release.apk | sort -rn
grep -oE 'android:(min|target)SdkVersion' .../processReleaseMainManifest/AndroidManifest.xml
grep -ci foreground .../processReleaseManifest/AndroidManifest.xml
git ls-files | wc -l ; du -sm '.gittt for gitlab'
grep -rniE '(api[_-]?key|secret|password|bearer)' lib --include='*.dart'
find lib -name '*.dart' -exec wc -l {} + | sort -rn
```

**Working tree left unchanged.** The only file touched during testing —
`android/gradle.properties` — was restored from backup and verified clean with
`git diff`. Build outputs under `build/` are gitignored.
