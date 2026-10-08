# iOS version — what is still needed

The release pipeline is built, committed and pushed (`e49f111` on
`fix_password_hint`). It cannot produce an installable app yet because **Apple
signing credentials cannot be created from this repo or from Windows** — they
need an Apple Developer membership and a Mac.

This file is the checklist of what *you* have to supply. The step-by-step
walkthrough for each item is in [`docs/ios_release_setup.md`](docs/ios_release_setup.md).

---

## 1. Accounts and hardware

- [ ] **Apple Developer Program membership** — $99/year, <https://developer.apple.com/programs/>
      Required. Free Apple IDs cannot create distribution certificates, so no
      installable build is possible without it. Enrolment as a company can take
      a few days (D-U-N-S verification); as an individual it is usually same-day.
- [ ] **A Mac, once** — to export the signing certificate as a `.p12`.
      Keychain Access only exists on macOS. After this one-time export the
      pipeline needs no Mac from you; GitHub's `macos-15` runners do the builds.
      No Mac at all? A short-term cloud Mac (MacStadium, Scaleway, AWS EC2 mac)
      or any colleague's Mac is enough for the 15 minutes this takes.
- [ ] **Owner/Editor access to Firebase project `test-8f18d`** — to enable App
      Distribution and create the service account.
- [ ] **Admin access to the GitHub repo** — to add Actions secrets.

---

## 2. Things to create

| # | What | Where | What you end up with |
|---|------|-------|----------------------|
| 1 | App ID for `tech.bilhikma.app`, with **Push Notifications** ticked | developer.apple.com → Identifiers | — |
| 2 | **APNs key** (`.p8`), uploaded into Firebase Cloud Messaging | developer.apple.com → Keys | `.p8` file + Key ID + Team ID |
| 3 | **Apple Distribution certificate**, exported with its private key | Keychain Access on a Mac → My Certificates → Export | `dist.p12` + a password you choose |
| 4 | **Ad Hoc provisioning profile** for that App ID and certificate | developer.apple.com → Profiles | `Bilhikma_AdHoc.mobileprovision` |
| 5 | **Firebase service account** with role *Firebase App Distribution Admin* | Firebase → Project settings → Service accounts | `firebase-sa.json` |

> Order matters: 1 → 3 → 4. The profile must be generated **after** the
> certificate, and must have that certificate selected, or signing fails.

> On step 3, export from **My Certificates** (not *Certificates*). The entry
> must have a disclosure triangle revealing a private key — without it the
> `.p12` is useless for signing.

---

## 3. GitHub secrets — all five are required

`Settings → Secrets and variables → Actions → New repository secret`

| Secret | Value |
|---|---|
| `IOS_DIST_CERT_P12_BASE64` | `base64 -i dist.p12 \| pbcopy` |
| `IOS_DIST_CERT_PASSWORD` | the password you set when exporting the `.p12` |
| `IOS_PROVISION_PROFILE_BASE64` | `base64 -i Bilhikma_AdHoc.mobileprovision \| pbcopy` |
| `FIREBASE_IOS_APP_ID` | `1:940046231017:ios:4c047fc493bb7703635778` ← already known, paste as-is |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | the entire contents of `firebase-sa.json` |

The helper script does the encoding and can upload all of them for you:

```bash
chmod +x scripts/ios_encode_secrets.sh
scripts/ios_encode_secrets.sh \
  --p12 ~/Desktop/dist.p12 \
  --profile ~/Desktop/Bilhikma_AdHoc.mobileprovision \
  --service-account ~/Desktop/firebase-sa.json \
  --push
```

It also prints the profile's name, UUID, expiry, `aps-environment` and device
count, so you can sanity-check it before the first run.

### Optional secrets

| Secret | Effect |
|---|---|
| `MAIL_USERNAME`, `MAIL_PASSWORD` | adds a second notification email on top of Firebase's. Gmail needs a 16-character [app password](https://myaccount.google.com/apppasswords), not your login password |
| `MAIL_SERVER`, `MAIL_PORT`, `MAIL_TO` | override SMTP host / port / recipient (defaults: `smtp.gmail.com`, `465`, the tester below) |
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | injects `GoogleService-Info.plist` at build time instead of using the committed one |
| `IOS_KEYCHAIN_PASSWORD` | fixed CI keychain password instead of a random one |
| `APP_STORE_CONNECT_KEY_ID` + `_ISSUER_ID` + `_KEY_P8_BASE64` | only for the TestFlight lane |

---

## 4. Firebase App Distribution

- [ ] Firebase console → **App Distribution** → Get started (one click, per project)
- [ ] **Testers & Groups** → add `mohammadwork199700@gmail.com`
- [ ] That tester accepts the invite email and installs the *Firebase App
      Tester* profile on their iPhone (one-time)

Every release then emails them an install link automatically. That is the
"send the app when it's done" step — nothing to do by hand.

---

## 5. Tester device UDIDs — the ad-hoc catch

An **Ad Hoc** build installs **only** on iPhones whose UDID is baked into the
provisioning profile. For each tester you need their UDID, then:

register UDID → regenerate the profile → update `IOS_PROVISION_PROFILE_BASE64`
→ rerun the workflow.

- [ ] Collect the UDID of every test device (Firebase App Distribution collects
      them for you under App Distribution → Testers, which is the easy route)

If tester churn becomes annoying, run the workflow with `export_method:
app-store` and distribute through TestFlight instead — no UDIDs needed, but
every build waits on Apple's processing. The `testflight_release` lane is
already written for this.

---

## 6. Running it, once the above is done

Fastest validation, on a Mac, before spending runner minutes:

```bash
cd ios && bundle install
bundle exec fastlane ios verify_setup
```

This decodes your profile and fails loudly on a wrong bundle id, an expired
profile or a missing push entitlement — in seconds.

Then from GitHub: **Actions → iOS Release → Run workflow**. Or by tag:

```bash
git tag ios-v1.0.0 && git push origin ios-v1.0.0
```

First run takes 20–40 minutes (cold pods and Flutter toolchain); later runs are
much faster.

---

## 7. Already done — do not redo

- `ios/` platform folder, bundle id `tech.bilhikma.app`, deployment target 15.0
- `GoogleService-Info.plist` present and bundled as an Xcode resource
- Push entitlements (`aps-environment`: development for Debug, production for
  Release/Profile) created and wired into `project.pbxproj` — these were
  missing, so push notifications would have silently failed in any release build
- `ios/Podfile` pinning pods to iOS 15.0 for `firebase_core` 4.x
- fastlane lanes, the GitHub Actions workflow, the secrets helper script and
  the setup docs
- `flutter analyze` is clean, so the CI analyze gate passes

---

## Known values, for copy-paste

| | |
|---|---|
| Bundle id | `tech.bilhikma.app` |
| Firebase project | `test-8f18d` |
| Firebase iOS app id | `1:940046231017:ios:4c047fc493bb7703635778` |
| Default tester | `mohammadwork199700@gmail.com` |
| Scheme / configuration | `Runner` / `Release` |
| Deployment target | iOS 15.0 |
| Flutter pinned in CI | 3.47.4 stable |
| Workflow | `.github/workflows/ios_release.yml` |
| Lanes | `ios/fastlane/Fastfile` |
| Full guide | `docs/ios_release_setup.md` |

---

## The short version

Everything on the software side is done. The only blocker is an **Apple
Developer membership plus one session on a Mac** to produce `dist.p12` and the
`.mobileprovision`. Add those two as secrets along with the Firebase service
account, and the pipeline emails the signed app to the tester on every run.
