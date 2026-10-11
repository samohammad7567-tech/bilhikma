import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing config, kept out of the repository. `android/.gitignore`
// already excludes key.properties and *.jks/*.keystore.
//
// Create android/key.properties with:
//   storeFile=/absolute/path/to/upload-keystore.jks
//   storePassword=...
//   keyAlias=upload
//   keyPassword=...
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "tech.bilhikma.app"

    // Pinned rather than inherited from `flutter.*`. Those track whatever the
    // installed Flutter ships, so a routine SDK upgrade could raise targetSdk
    // underneath a published app and opt it into new platform behaviour
    // (foreground-service types, broadcast limits) with no code change here.
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "tech.bilhikma.app"

        // Android 7.0. Below this media3/ExoPlayer and several plugins no
        // longer build, and above it would drop devices this app is meant to
        // reach. Raise only with a deliberate decision about who it excludes.
        minSdk = 24
        targetSdk = 35

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = keystoreProperties.getProperty("storeFile")?.let(::file)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // A debug-signed release is per-machine and expires: a user who
            // already installed a build signed elsewhere cannot update it
            // (INSTALL_FAILED_UPDATE_INCOMPATIBLE), and some OEM installers
            // report that as a corrupt package. Anything shipped to a user
            // must use the real keystore.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING android/key.properties not found — signing the " +
                        "release build with the debug key. This build is for " +
                        "local testing only and must not be distributed."
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
