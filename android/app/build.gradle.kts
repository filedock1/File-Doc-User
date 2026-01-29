import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // FlutterFire
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load local.properties
val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        load(localPropertiesFile.inputStream())
    }
}

// Ensure minSdk is at least 24
val flutterMinSdkVersion =
    (localProperties.getProperty("flutter.minSdkVersion")?.toInt() ?: 24).coerceAtLeast(24)

android {
    namespace = "com.ignito.filedockuser"
    compileSdk = 36   // ✅ required by latest plugins
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ignito.filedockuser"
        minSdk = flutterMinSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        manifestPlaceholders.putAll(
            mapOf(
              "permissionHandlerPermissionGroups" to "storage,photos,videos"
          )
)

    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.android.gms:play-services-ads:23.4.0")
}



flutter {
    source = "../.."
}
