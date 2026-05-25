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

// Read MAPBOX_ACCESS_TOKEN from (in order): a project-local key.properties file,
// the environment, and finally an empty string. The empty fallback keeps debug
// builds working when a developer hasn't set the token yet — the map will fail
// to authenticate at runtime, but the build won't break.
val mapboxAccessToken: String = run {
    val localProps = rootProject.file("../app/android/key.properties")
        .takeIf { it.exists() }
        ?.let { Properties().apply { load(it.inputStream()) } }
    localProps?.getProperty("MAPBOX_ACCESS_TOKEN")
        ?: System.getenv("MAPBOX_ACCESS_TOKEN")
        ?: providers.gradleProperty("MAPBOX_ACCESS_TOKEN").orNull
        ?: ""
}

android {
    namespace = "org.afairresolution.kapok"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "org.afairresolution.kapok"
        // mapbox_maps_flutter requires minSdk 21; multiDex required for large dependency graphs
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["MAPBOX_ACCESS_TOKEN"] = mapboxAccessToken
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
