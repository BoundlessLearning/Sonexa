plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.sonexa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.sonexa"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

val exportReleaseApkAsSonexa by tasks.registering {
    doLast {
        val candidateApks = listOf(
            layout.buildDirectory.file("outputs/flutter-apk/app-release.apk").get().asFile,
            layout.buildDirectory.file("outputs/apk/release/app-release.apk").get().asFile,
        )

        val sourceApk = candidateApks.firstOrNull { it.exists() } ?: return@doLast
        val exportDir = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
        if (!exportDir.exists()) {
            exportDir.mkdirs()
        }

        sourceApk.copyTo(exportDir.resolve("sonexa.apk"), overwrite = true)
    }
}

tasks.matching { it.name == "assembleRelease" }.configureEach {
    finalizedBy(exportReleaseApkAsSonexa)
}

flutter {
    source = "../.."
}
