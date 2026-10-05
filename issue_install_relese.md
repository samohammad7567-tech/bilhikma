# Release APK install failure — "لم يتم تثبيت التطبيق لأن الحزمة تبدو غير صالحة"

**Device:** Redmi A7 Pro · Android 16 (HyperOS)
**Build:** `flutter build apk --release` · Flutter 3.47.4 · `tech.bilhikma.app` v1.0.0+2

---

## 1. Verdict

**The APK is not corrupt and not malformed. The file that was copied to the phone is for the wrong CPU architecture (ABI).**

The build output contains **only split-per-ABI APKs** — there is no universal `app-release.apk`:

```
build/app/outputs/flutter-apk/
  app-arm64-v8a-release.apk      (29.6 MB)   versionCode 2002
  app-armeabi-v7a-release.apk    (27.9 MB)   versionCode 1002
  app-x86_64-release.apk         (31.2 MB)   versionCode 4002
```

That output shape is only produced by `flutter build apk --split-per-abi`, not by a plain `--release`. So the command that actually ran included `--split-per-abi` (or was invoked from a script/alias that adds it).

Redmi A7 Pro is an **arm64-v8a** device, and Android 16 ships on it as a **64-bit-only** runtime. Installing `app-x86_64-release.apk` (Intel) or `app-armeabi-v7a-release.apk` (32-bit ARM) on it fails with `INSTALL_FAILED_NO_MATCHING_ABIS`, which HyperOS's installer UI renders exactly as:

> لم يتم تثبيت التطبيق لأن الحزمة تبدو غير صالحة.

The wording is misleading — the package is valid, it just carries no native library the device can load.

### Evidence — the APK itself is healthy

Everything that normally causes a genuine "invalid package" was checked and passed:

| Check | Result |
|---|---|
| Signature (`apksigner verify`) | ✅ Verifies — APK Signature Scheme **v2: true** |
| `minSdkVersion` | ✅ 24 (device is API 36 — compatible) |
| `targetSdkVersion` | ✅ 36 (meets the Android 14+ minimum target of 24) |
| 16 KB page alignment (`zipalign -c -P 16`) | ✅ Verification successful — all 4 `.so` files OK |
| Android 16 / `compileSdk` | ✅ 36 |
| Manifest / `applicationId` | ✅ `tech.bilhikma.app` |
| `native-code` in arm64 APK | ✅ `arm64-v8a` only |

So there is nothing wrong with the binary — the wrong one was transferred.

---

## 2. Fix (pick one)

### Option A — install the matching split (fastest)

```bash
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Copy **that** file to the Redmi A7 Pro. Confirm the device ABI first if you want to be sure:

```bash
adb shell getprop ro.product.cpu.abilist
# expected: arm64-v8a,  (64-bit only on Android 16 Redmi A-series)
```

### Option B — build one universal APK that installs on every phone

```bash
flutter build apk --release
```

with **no** `--split-per-abi`. That produces a single `build/app/outputs/flutter-apk/app-release.apk` containing all ABIs — larger (~60 MB) but it installs anywhere. This is the right choice for manual/QA distribution over WhatsApp, Telegram, Drive, etc.

### Option C — install over ADB and read the real error

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

ADB prints the actual failure reason (`INSTALL_FAILED_NO_MATCHING_ABIS`, `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, …) instead of the vague Arabic string.

---

## 3. Second, independent problem — release is signed with the DEBUG key

`android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")   // ⚠️
    }
}
```

Confirmed on the built artifact:

```
Signer #1 certificate DN: C=US, O=Android, CN=Android Debug
```

There is **no** `android/key.properties` and **no** `.jks` keystore anywhere in the project.

This did not cause the error above, but it is a real blocker you will hit next:

1. **Play Store will reject it** — Google Play refuses APK/AAB signed with the Android debug certificate.
2. **Not reproducible across machines** — `~/.android/debug.keystore` is per-developer, so a build from CI or a teammate's PC produces a *different* signature. Installing it over an existing build fails with `INSTALL_FAILED_UPDATE_INCOMPATIBLE` ("signatures do not match").
3. **Play Protect / HyperOS friction** — debug-signed sideloads trigger extra "blocked by Play Protect" / "harmful app" warnings on Android 14+, and on some HyperOS builds installation is refused outright.
4. **Firebase mismatch** — the debug SHA-1 (`9ffae0b7…`) must be registered in the Firebase console or Google Sign-In / FCM silently fails in release.
5. `v3: false` — only the v2 scheme is applied; a proper release keystore config with AGP 8.11 also emits v3, which is what key rotation depends on.

### Recommended fix

```bash
keytool -genkey -v -keystore android/app/bilhikma-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias bilhikma
```

`android/key.properties` (**add to `.gitignore` — never commit it**):

```properties
storePassword=<...>
keyPassword=<...>
keyAlias=bilhikma
storeFile=bilhikma-release.jks
```

`android/app/build.gradle.kts`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

Then register the new release SHA-1 / SHA-256 in the Firebase console (`google-services.json` is applied conditionally in this project).

---

## 4. Summary

| # | Problem | Severity | Status |
|---|---|---|---|
| 1 | Wrong-ABI split APK copied to an arm64-only Android 16 device | 🔴 Causes the reported error | Install `app-arm64-v8a-release.apk`, or rebuild without `--split-per-abi` |
| 2 | `release` buildType signed with the **debug** keystore | 🟠 Blocks Play release, breaks updates across machines | Create a release keystore + `key.properties` |

Nothing is wrong with the code, the manifest, the SDK levels, or the 16 KB page alignment — all verified clean against Android 16 / API 36.
