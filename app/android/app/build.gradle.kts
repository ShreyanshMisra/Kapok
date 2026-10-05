import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// app/android/key.properties (gitignored) holds release signing credentials and
// optionally MAPBOX_ACCESS_TOKEN. See docs/15_store_readiness_evaluation.md §2.2.
val keyProperties: Properties? = rootProject.file("key.properties")
    .takeIf { it.exists() }
    ?.let { file -> Properties().apply { file.inputStream().use { load(it) } } }

// Read MAPBOX_ACCESS_TOKEN from (in order): key.properties, the environment,
// a Gradle property, and finally an empty string. The empty fallback keeps
// debug builds working when a developer hasn't set the token yet — the map will
// fail to authenticate at runtime, but the build won't break.
val mapboxAccessToken: String = run {
    keyProperties?.getProperty("MAPBOX_ACCESS_TOKEN")
        ?: System.getenv("MAPBOX_ACCESS_TOKEN")
        ?: providers.gradleProperty("MAPBOX_ACCESS_TOKEN").orNull
        ?: ""
}

android {
    namespace = "com.afairresolution.kapok"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.afairresolution.kapok"
        // mapbox_maps_flutter requires minSdk 21; multiDex required for large dependency graphs
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["MAPBOX_ACCESS_TOKEN"] = mapboxAccessToken
    }

    signingConfigs {
        if (keyProperties?.getProperty("storeFile") != null) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Uses the upload key from key.properties when present. Without it,
            // falls back to debug keys so `flutter run --release` still works
            // locally — Play Console rejects debug-signed bundles.
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
