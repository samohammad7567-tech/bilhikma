plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "tech.bilhikma.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications (Android 13+ notification APIs) needs
        // this even though we don't otherwise touch Java 8+ APIs directly.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "tech.bilhikma.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
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

// Only wires in Firebase once google-services.json actually exists — register
// the Android app in the Firebase console with applicationId
// "tech.bilhikma.app", download that file into android/app/, and this
// activates on the next build automatically. Applying the plugin
// unconditionally would fail every build for everyone until then.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
