import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val posthogProperties = Properties()
val posthogPropertiesFile = rootProject.file("posthog.properties")
if (posthogPropertiesFile.exists()) {
    posthogProperties.load(FileInputStream(posthogPropertiesFile))
} else {
    // Use placeholder values if file doesn't exist
    // Developers should copy posthog.properties.example to posthog.properties
    posthogProperties.setProperty("POSTHOG_API_KEY", "YOUR_POSTHOG_API_KEY_HERE")
    posthogProperties.setProperty("POSTHOG_HOST", "https://eu.i.posthog.com")
}

android {
    namespace = "org.nostrpay.app"
    compileSdk = 36
    ndkVersion = "28.0.12916984"

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // Sets Java compatibility to Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.nostrpay.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        // PostHog configuration from properties file
        manifestPlaceholders["posthogApiKey"] = posthogProperties.getProperty("POSTHOG_API_KEY", "")
        manifestPlaceholders["posthogHost"] = posthogProperties.getProperty("POSTHOG_HOST", "https://eu.i.posthog.com")
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            // Filter to 64-bit architectures only for 16KB page size compatibility
            ndk {
                abiFilters += listOf("arm64-v8a")
                // Enable debug symbols for crash reporting
                debugSymbolLevel = "FULL"
            }
            // Enables code-related app optimization.
            isMinifyEnabled = true
            // Enables resource shrinking.
            isShrinkResources = true
            proguardFiles(
                // Default file with automatically generated optimization rules.
                getDefaultProguardFile("proguard-android-optimize.txt"),
            )

        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
