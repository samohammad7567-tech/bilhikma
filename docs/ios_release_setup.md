# iOS release pipeline — setup guide

Signed iOS build → Firebase App Distribution → install email to the testers.

**Pipeline:** GitHub Actions (`macos-15`) → fastlane (`gym`) → Firebase App
Distribution → email to `mohammadwork199700@gmail.com`.

| Thing | Value |
|---|---|
| Bundle id | `tech.bilhikma.app` |
| Scheme / configuration | `Runner` / `Release` |
| Deployment target | iOS 15.0 |
| Firebase project | `test-8f18d` |
| Firebase iOS app id | `1:940046231017:ios:4c047fc493bb7703635778` |
| Default tester | `mohammadwork199700@gmail.com` |
| Workflow | `.github/workflows/ios_release.yml` |
| Lanes | `ios/fastlane/Fastfile` |

---

## Files this pipeline added

```
.github/workflows/ios_release.yml     CI entry point
ios/Gemfile                           fastlane + CocoaPods, version-pinned
ios/Podfile                           pins pods to iOS 15.0, disables bitcode
ios/fastlane/Appfile                  bundle id, Apple id/team from env
ios/fastlane/Pluginfile               firebase_app_distribution plugin
ios/fastlane/Fastfile                 verify_setup / build_only / distribute / testflight_release
ios/Runner/Runner.entitlements        aps-environment = development  (Debug)
ios/Runner/RunnerRelease.entitlements aps-environment = production   (Release, Profile)
scripts/ios_encode_secrets.sh         encodes signing material into base64 secrets
```

`Runner.xcodeproj` was edited to reference both entitlements files, so push
notifications keep working in release builds. Everything else about signing is
set at build time by fastlane — the project stays on automatic signing for
local Xcode work.

---

## One-time Apple setup

Needs a paid **Apple Developer Program** membership ($99/yr). All of this
happens on a Mac, or in the portal at <https://developer.apple.com/account>.

### 1. App ID

Certificates, Identifiers & Profiles → **Identifiers** → `+` → App IDs → App.

- Bundle ID: **Explicit** → `tech.bilhikma.app`
- Capabilities: tick **Push Notifications** (the app uses `firebase_messaging`)

### 2. APNs key (for Firebase push)

**Keys** → `+` → tick **Apple Push Notifications service (APNs)** → download
the `.p8` **once** (it cannot be re-downloaded).

Upload it in Firebase console → Project settings → **Cloud Messaging** → iOS
app → *APNs Authentication Key*. You will need the Key ID and your Team ID.

### 3. Distribution certificate → `.p12`

On a Mac:

```bash
# Keychain Access → Certificate Assistant → Request a Certificate From a
# Certificate Authority…  → save to disk  → upload the CSR in the portal under
# Certificates → + → Apple Distribution → download the .cer → double-click it.
#
# Then export it WITH its private key:
#   Keychain Access → login → My Certificates → "Apple Distribution: …"
#   right-click → Export → Personal Information Exchange (.p12)
#   set a password — that password becomes IOS_DIST_CERT_PASSWORD
```

### 4. Provisioning profile

**Profiles** → `+`:

- For Firebase App Distribution → **Ad Hoc**
- For TestFlight / App Store → **App Store**

Pick App ID `tech.bilhikma.app`, pick the distribution certificate from step 3,
and for Ad Hoc select the devices. Download the `.mobileprovision`.

> **Ad Hoc builds only install on devices whose UDID is in the profile.** Each
> new tester means: register the UDID → regenerate the profile → update the
> `IOS_PROVISION_PROFILE_BASE64` secret → rerun the workflow. Firebase App
> Distribution collects tester UDIDs for you (console → App Distribution →
> Testers), which makes this less painful. If the tester churn gets annoying,
> switch to `export_method: app-store` and distribute through TestFlight
> instead — no UDIDs, but each build waits on Apple processing.

### 5. Firebase service account

Firebase console → Project settings → **Service accounts** → *Manage service
account permissions* → create a service account with the
**Firebase App Distribution Admin** role → *Keys* → Add key → JSON → download.

---

## Repository secrets

`Settings → Secrets and variables → Actions → New repository secret`

### Required

| Secret | How to get it |
|---|---|
| `IOS_DIST_CERT_P12_BASE64` | `base64 -i dist.p12 \| pbcopy` |
| `IOS_DIST_CERT_PASSWORD` | the password you set when exporting the `.p12` |
| `IOS_PROVISION_PROFILE_BASE64` | `base64 -i profile.mobileprovision \| pbcopy` |
| `FIREBASE_IOS_APP_ID` | `1:940046231017:ios:4c047fc493bb7703635778` |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | the whole service-account JSON file, pasted raw |

### Optional

| Secret | Effect when set |
|---|---|
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | overwrites the committed `GoogleService-Info.plist` at build time |
| `IOS_KEYCHAIN_PASSWORD` | fixed CI keychain password instead of a random one |
| `MAIL_USERNAME`, `MAIL_PASSWORD` | enables the extra SMTP notification email |
| `MAIL_SERVER`, `MAIL_PORT`, `MAIL_TO` | override SMTP host/port/recipient (defaults: `smtp.gmail.com`, `465`, the tester address) |
| `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_P8_BASE64` | required by the `testflight_release` lane |

`MAIL_PASSWORD` for Gmail must be a **16-character app password**
(<https://myaccount.google.com/apppasswords>), not the account password.

The helper script does the encoding and can push the secrets for you:

```bash
chmod +x scripts/ios_encode_secrets.sh
scripts/ios_encode_secrets.sh \
  --p12 ~/Desktop/bilhikma_dist.p12 \
  --profile ~/Desktop/Bilhikma_AdHoc.mobileprovision \
  --service-account ~/Desktop/firebase-sa.json \
  --push          # omit --push to just write the values to ~/Desktop
```

It also prints the profile's name, UUID, expiry, `aps-environment` and device
count — worth checking before the first run.

---

## Firebase App Distribution

1. Firebase console → **App Distribution** → Get started.
2. **Testers & Groups** → add `mohammadwork199700@gmail.com`.
3. Optionally create a group (e.g. `qa`) and pass its alias as the
   `tester_groups` workflow input or the `FIREBASE_TESTER_GROUPS` env var.

The tester gets an email from Firebase on every release with an install link.
That email is the "send the app when it's finished" step — no manual sending.
They must accept the invite once and install the Firebase App Tester profile on
the device.

---

## Running it

### From the GitHub UI

**Actions → iOS Release → Run workflow**, with inputs:

| Input | Default | Notes |
|---|---|---|
| `export_method` | `ad-hoc` | `app-store` for TestFlight-style archives |
| `testers` | *(blank)* | comma-separated emails; blank uses the Fastfile default |
| `tester_groups` | *(blank)* | Firebase group aliases |
| `release_notes` | *(blank)* | blank auto-generates from version + last 5 commits |
| `build_number` | *(blank)* | blank uses `100 + run number` |

### From a tag

```bash
git tag ios-v1.0.0
git push origin ios-v1.0.0
```

### Locally on a Mac

```bash
cd ios && bundle install

export IOS_DIST_CERT_P12_BASE64="$(base64 -i ~/Desktop/dist.p12)"
export IOS_DIST_CERT_PASSWORD='…'
export IOS_PROVISION_PROFILE_BASE64="$(base64 -i ~/Desktop/profile.mobileprovision)"
export FIREBASE_IOS_APP_ID='1:940046231017:ios:4c047fc493bb7703635778'
export FIREBASE_SERVICE_ACCOUNT_FILE=~/Desktop/firebase-sa.json

bundle exec fastlane ios verify_setup        # credentials check, no build

cd .. && flutter build ios --release --no-codesign --build-number 101
cd ios && bundle exec fastlane ios distribute
```

`verify_setup` is the fastest way to confirm the secrets are right — it decodes
the profile and fails loudly on a bundle-id mismatch or an expired profile
without burning 20 minutes of build time.

---

## Build numbers

`CFBundleVersion` comes from `FLUTTER_BUILD_NUMBER`, which the workflow passes
as `--build-number`. The default is `BUILD_NUMBER_BASE (100) + run number`, so
CI numbers always sit above the `+8` in `pubspec.yaml` and never collide.
`pubspec.yaml` is not rewritten by CI.

Bump `version:` in `pubspec.yaml` for the marketing version (`1.0.0`); the
build number takes care of itself.

---

## Troubleshooting

**`No signing certificate "iOS Distribution" found`**
The `.p12` has no private key, or the password is wrong. Re-export from
*My Certificates* (not *Certificates*) in Keychain Access — the entry must have
a disclosure triangle revealing a private key.

**`Provisioning profile … doesn't include signing certificate`**
The profile was generated against a different certificate. Regenerate it in the
portal picking the certificate you exported.

**`Profile is for X, but the app bundle id is tech.bilhikma.app`**
`verify_setup` caught a mismatched profile. Generate one for `tech.bilhikma.app`.

**Tester can install but push notifications never arrive**
Check the APNs key is uploaded in Firebase (step 2), that the App ID has the
Push Notifications capability, and that the profile shows
`aps-environment: production` — `scripts/ios_encode_secrets.sh` prints it.

**`App Distribution: Failed to fetch app`**
`FIREBASE_IOS_APP_ID` is wrong, or the service account lacks the
*Firebase App Distribution Admin* role.

**Tester gets the email but install fails**
Ad-hoc profile missing their UDID. Register it, regenerate the profile, update
the secret, rerun.

**`pod: command not found` / CocoaPods crashes in CI**
The *Expose bundled CocoaPods on PATH* step handles this. If it fails, commit
`ios/Gemfile.lock` (generate it with `cd ios && bundle install` on a Mac).

**First run is slow**
20–40 minutes is normal — pods and the Flutter iOS toolchain are cold. Later
runs reuse the Flutter cache and the bundler cache.

---

## Still missing / next steps

- `ios/Podfile.lock` and `ios/Gemfile.lock` do not exist yet (they can only be
  generated on macOS). Commit both after the first Mac run for fully
  reproducible builds.
- `ios/Runner/Assets.xcassets` app icon — verify it has every required size, or
  App Store export will be rejected.
- No `ios/RunnerTests` coverage; the workflow's test step is a no-op until
  `test/*_test.dart` files exist.
- Android has no equivalent workflow yet; `devops.md` sections 1–5 cover it.
