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
// a Gradle property, and finally app/.env (the same file the Dart side loads).
// Debug builds tolerate a missing token (the map just won't authenticate);
// bundleRelease fails instead — see the check at the bottom of this file.
val mapboxAccessToken: String = run {
    keyProperties?.getProperty("MAPBOX_ACCESS_TOKEN")?.takeIf { it.isNotBlank() }
        ?: System.getenv("MAPBOX_ACCESS_TOKEN")?.takeIf { it.isNotBlank() }
        ?: providers.gradleProperty("MAPBOX_ACCESS_TOKEN").orNull?.takeIf { it.isNotBlank() }
        ?: rootProject.file("../.env").takeIf { it.exists() }?.readLines()
            ?.map { it.trim() }
            ?.firstOrNull { it.startsWith("MAPBOX_ACCESS_TOKEN=") }
            ?.substringAfter("=")?.trim()?.trim('"', '\'')
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

// Play Console rejects debug-signed bundles, and a bundle without a Mapbox
// token ships a blank map. Fail the store build instead of falling back
// silently. (`flutter run --release` / assembleRelease still fall back.)
gradle.taskGraph.whenReady {
    val buildingStoreBundle = allTasks.any {
        it.project == project && it.name == "bundleRelease"
    }
    if (buildingStoreBundle) {
        if (android.signingConfigs.findByName("release") == null) {
            throw GradleException(
                "bundleRelease needs the upload key: create app/android/key.properties " +
                    "(see key.properties.example)."
            )
        }
        if (!mapboxAccessToken.startsWith("pk.")) {
            throw GradleException(
                "bundleRelease needs a public Mapbox token (pk.*): set MAPBOX_ACCESS_TOKEN " +
                    "in app/.env or app/android/key.properties."
            )
        }
    }
}
