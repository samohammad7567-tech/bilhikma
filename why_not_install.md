# "App not installed" — why the APK is refused

**Artifact analysed:** `build/app/outputs/flutter-apk/BilHikma-v1.0.0+10-build-2026-10-10.apk`

- Size `78,122,907` bytes (78.12 MB) — **identical** to the size shown in the phone Downloads
  screen, so the download is complete and the file is not truncated.
- SHA-1 `e2dac7ea497fc09b01ea4db1d59173fb9242179f` — matches `app-release.apk.sha1` produced by
  the build, so the file was not altered by renaming or upload.
- ABIs present: `armeabi-v7a`, `arm64-v8a`, `x86_64` — it is a **universal** APK, so a wrong-ABI
  refusal is ruled out.
- `package = tech.bilhikma.app`, `versionName 1.0.0`, `versionCode 10`, `minSdk 24`.

The installer dialog in the screenshot shows the app **icon and Arabic name (بالحكمة)** before
failing. That only happens after Android has successfully parsed the package. So the package is
*valid*; it is being **rejected at the commit stage**, not at the parse stage. That eliminates
"corrupt APK" and points at signature / version / policy conflicts.

---

## 0. Summary table

| # | Cause | Status for this build | Underlying installer error |
|---|---|---|---|
| 1 | **Release APK is signed with the DEBUG key** | **CONFIRMED IN THE FILE** | `INSTALL_FAILED_UPDATE_INCOMPATIBLE` |
| 2 | Signature conflict with an already-installed `tech.bilhikma.app` | **MOST LIKELY TRIGGER** | `INSTALL_FAILED_UPDATE_INCOMPATIBLE` |
| 3 | No v1 (JAR) signature — v2/v3 only | Confirmed present, **harmless at minSdk 24** | `INSTALL_PARSE_FAILED_NO_CERTIFICATES` (only below API 24) |
| 4 | versionCode downgrade (installed build has a higher code) | Possible — this build is only `10` | `INSTALL_FAILED_VERSION_DOWNGRADE` |
| 5 | Play Protect blocking a debug-signed sideload | Possible | `INSTALL_FAILED_VERIFICATION_FAILURE` |
| 6 | "Install unknown apps" not granted to Chrome / Files | Possible | session aborted, no code |
| 7 | Leftover registration from a previous uninstall / second user | Possible | `INSTALL_FAILED_ALREADY_EXISTS` |
| 8 | Device below API 24, or a per-ABI split handed out | Ruled out for this APK | `INSTALL_FAILED_OLDER_SDK` / `_NO_MATCHING_ABIS` |
| 9 | Insufficient free space (needs about 2x the 78 MB) | Ruled out (112 GB free) | `INSTALL_FAILED_INSUFFICIENT_STORAGE` |
| 10 | MDM / work-profile / OEM install policy | Possible on managed devices | `INSTALL_FAILED_USER_RESTRICTED` |

---

## 1. CONFIRMED — this APK is signed with the Android **debug** certificate

Reading the APK Signing Block of the distributed file directly, the signer certificate is:

```
CN = Android Debug,  O = Android,  C = US
valid 2026-04-20 -> 2056-04-12
```

That is the generic `~/.android/debug.keystore` certificate, **not** a release key.

Why it happened — `android/app/build.gradle.kts` deliberately falls back:

```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
...
signingConfig = if (hasReleaseKeystore) signingConfigs.getByName("release")
                else signingConfigs.getByName("debug")   // <- this branch ran
```

**`android/key.properties` does not exist in this working tree.** A listing of `android/` shows
only `gradle.properties` and `local.properties`. So `flutter build apk --release` silently
produced a debug-signed release and only printed a warning.

It also means `scripts/build_release.sh` was **not** used to produce this APK — that script
hard-fails when `key.properties` is missing:

```
ERROR android/key.properties not found.
      A release signed with the debug key cannot be distributed...
```

### Why a debug-signed build fails to install

- The debug key is **per machine and per user account**. An APK built on your laptop and an APK
  built on a colleague machine (or on CI) carry *different* signatures even though the package
  name is identical. Android refuses to replace an installed app with a differently-signed one:
  `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, which most OEM installers render as exactly the bare
  **"App not installed"** dialog in the screenshot.
- Any tester who ever installed a build from Play internal testing, from App Distribution, or
  from a different machine is permanently blocked from this APK.
- Google Play rejects debug-signed uploads outright.

### Fix

1. Create the release keystore once (keep the `.jks` **outside** the repo and back it up —
   losing it means you can never update the app on Play again):
   ```bash
   keytool -genkey -v -keystore ~/bilhikma-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (already git-ignored):
   ```properties
   storeFile=C:/Users/IRD-83/keys/bilhikma-upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. Build through the script, never by hand:
   ```bash
   bash scripts/build_release.sh
   ```
4. Verify before distributing:
   ```bash
   apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
   ```
   The printed `CN` must be yours. If it says `Android Debug`, do not ship it.

---

## 2. MOST LIKELY TRIGGER — a copy of `tech.bilhikma.app` is already on the phone

`applicationId = "tech.bilhikma.app"` is fixed — no `.dev` / `.staging` suffix, no flavors — so
**every** build (debug, profile, release, CI, Play) claims the same package slot on the device.
Combined with §1, any previously installed copy signed by a different key blocks this one.

The installer showing the app own icon and the name **بالحكمة** before failing is the classic
signature of an *upgrade* attempt, not a fresh install.

### Confirm it on the phone

```bash
adb shell pm list packages | findstr bilhikma
adb install -r -d "build/app/outputs/flutter-apk/BilHikma-v1.0.0+10-build-2026-10-10.apk"
```

`adb install` prints the real reason; the Downloads UI hides it.

### Fix

- Uninstall the old copy first: `adb uninstall tech.bilhikma.app` (or Settings -> Apps ->
  بالحكمة -> Uninstall), then install the new APK.
- Check the "other user" case too — an app installed under a second user or work profile stays
  on disk and still blocks: `adb shell pm uninstall -k --user 0 tech.bilhikma.app`.
- Long term, give debug builds their own id so they can co-exist with release builds:
  ```kotlin
  buildTypes { debug { applicationIdSuffix = ".debug"; versionNameSuffix = "-debug" } }
  ```

---

## 3. The APK has **no v1 (JAR) signature** — v2/v3 only

`META-INF/` contains no `CERT.RSA` / `CERT.SF` / `MANIFEST.MF`; the only signature is the APK
Signing Block (v2/v3) found at offset `78081424`.

- This is **correct and harmless here**: v2 verification exists from Android 7.0, and
  `minSdk = 24` is Android 7.0.
- It becomes fatal only if `minSdk` is ever lowered below 24, or if a tool re-zips the APK after
  signing. Any post-processing — repacking, `zip -d`, some upload pipelines — breaks the v2 block,
  and the installer then reports a parse/certificate failure.
- **Rule:** rename the APK freely, but never re-zip or modify it after signing. Renaming is safe
  and was done correctly here (the SHA-1 still matches the build output).

---

## 4. versionCode downgrade

`versionCode = flutter.versionCode` resolves to `10`, from `version: 1.0.0+10` in `pubspec.yaml`.

Android refuses to install a package whose `versionCode` is **lower** than the installed one
(`INSTALL_FAILED_VERSION_DOWNGRADE`) unless `-d` is passed to `adb install`, which the Downloads
installer never does. If the tester has an older build numbered `+11`, `+12`, a timestamp such as
`+2026101001`, or a Play build, then this APK is a downgrade and is refused.

### Check / fix

```bash
adb shell dumpsys package tech.bilhikma.app | findstr versionCode
```

Keep `versionCode` strictly monotonic — never reuse or lower it, and never mix a timestamp scheme
with a counter scheme across builds of the same package.

---

## 5. Play Protect blocks the install

Play Protect scans every sideloaded APK. A **debug-signed**, unknown-reputation 78 MB APK
downloaded from a Drive link is exactly its profile for a block, and on several OEM skins the
refusal surfaces as a plain "App not installed" with no explanation.

Contributing factors in this build:

- Debug certificate (§1) — zero install reputation.
- Broad permission set in `AndroidManifest.xml`: `FOREGROUND_SERVICE_MEDIA_PLAYBACK`,
  `DETECT_SCREEN_CAPTURE`, `POST_NOTIFICATIONS`, `WAKE_LOCK`, plus an exported `AudioService` and
  an exported `MediaButtonReceiver`.

### Fix

- Play Protect -> settings gear -> temporarily turn off "Scan apps with Play Protect", install,
  turn it back on.
- Better: distribute through **Firebase App Distribution** or Play internal testing with a real
  release key instead of a raw APK link.

---

## 6. "Install unknown apps" not granted to the installing app

The APK came from a Drive / `google.com` link, so the *installer* is Chrome or the Files app, not
the Downloads list. Each app needs its own grant:
**Settings -> Apps -> Special access -> Install unknown apps -> Chrome / Files -> Allow.**
Without it the session is aborted, and some skins show "App not installed" rather than the
permission prompt.

---

## 7. Leftover data from a previous uninstall

If the app was uninstalled while another Android user or profile still had it, or if an uninstall
was interrupted, the package can stay half-registered. Symptom: reinstall fails with "App not
installed" even though the app is not in the launcher.

```bash
adb shell pm list packages --user all | findstr bilhikma
adb shell pm uninstall --user 0 tech.bilhikma.app
```

Reboot the phone and retry — a reboot also clears a stuck `PackageInstaller` session.

---

## 8. Device / ABI / SDK mismatch — ruled out for this file, but easy to reintroduce

- `minSdk = 24`, so anything on Android 6.0 or lower gets `INSTALL_FAILED_OLDER_SDK`.
- The distributed APK is universal (`armeabi-v7a`, `arm64-v8a`, `x86_64`), so
  `INSTALL_FAILED_NO_MATCHING_ABIS` cannot happen with **this** file.
- It **will** happen if anyone hands out a per-ABI split instead. `flutter build apk
  --split-per-abi` writes three identical-looking files into the same folder:
  ```
  app-armeabi-v7a-release.apk
  app-arm64-v8a-release.apk
  app-x86_64-release.apk
  ```
  Give a 32-bit phone the `arm64-v8a` one and the install is refused; some OEM installers render
  it as "the package appears to be invalid". This is already documented in
  `scripts/build_release.sh` and in `issues.md` §1.1 — the script exists precisely to prevent it.
- Note `x86_64` is shipped but `x86` is not, so a 32-bit emulator image would be refused.

---

## 9. Storage — ruled out

Android needs roughly 2x the APK size free during install (about 160 MB here) plus room for the
extracted native libraries. The screenshot shows **112.57 GB** available, so this is not the cause.

---

## 10. Managed device / OEM restriction

On a work profile or MDM-enrolled device, `DISALLOW_INSTALL_UNKNOWN_SOURCES` produces
`INSTALL_FAILED_USER_RESTRICTED` with the same generic dialog. Some OEM skins (MIUI, ColorOS,
EMUI) also require their own toggle ("Install via USB", "Verify apps over USB") or an active
account before allowing a sideload.

---

## 11. The one command that answers it in five seconds

The Downloads dialog deliberately hides the reason. Plug the phone in and run:

```bash
adb install -r "build/app/outputs/flutter-apk/BilHikma-v1.0.0+10-build-2026-10-10.apk"
```

or watch the installer live:

```bash
adb logcat -c
# tap install on the phone
adb logcat | findstr /i "PackageManager PackageInstaller INSTALL_FAILED"
```

Map the printed code:

| Printed code | Section above |
|---|---|
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` / `..._SIGNATURE` | §1 + §2 — signature conflict |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | §4 |
| `INSTALL_FAILED_VERIFICATION_FAILURE` | §5 — Play Protect |
| `INSTALL_FAILED_NO_MATCHING_ABIS` | §8 — wrong split handed out |
| `INSTALL_FAILED_OLDER_SDK` | §8 — device below Android 7.0 |
| `INSTALL_FAILED_INSUFFICIENT_STORAGE` | §9 |
| `INSTALL_FAILED_USER_RESTRICTED` | §6 / §10 |
| `INSTALL_PARSE_FAILED_*` | §3 — APK modified after signing |

---

## 12. Action list, in order

1. **Create `android/key.properties` and the release keystore**, then rebuild. This is the only
   confirmed defect in the artifact. (§1)
2. **Always build with `bash scripts/build_release.sh`** — it refuses to run without the keystore
   and verifies both required ABIs are in the APK.
3. **Verify the signer** with `apksigner verify --print-certs` before sending any APK out.
4. **Uninstall the old copy on the test phone** before installing the newly signed APK. The first
   install after switching from the debug key to a release key *always* requires an uninstall, for
   every tester — tell them explicitly.
5. **Bump `versionCode`** on every distributed build and never go backwards. (§4)
6. **Add `applicationIdSuffix = ".debug"`** to the debug build type so debug and release builds
   stop fighting over the same package slot. (§2)
7. For anything beyond one or two testers, move to **Firebase App Distribution** or Play internal
   testing — both avoid Play Protect blocks and the unknown-sources prompt. (§5, §6)
