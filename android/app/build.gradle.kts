import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystore = keystorePropertiesFile.exists()
if (hasKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.deshi.postermaker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.deshi.postermaker"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasKeystore) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val storeFileProp = keystoreProperties.getProperty("storeFile", "upload-keystore.jks")
                storeFile = when {
                    file(storeFileProp).exists() -> file(storeFileProp)
                    file("app/$storeFileProp").exists() -> file("app/$storeFileProp")
                    rootProject.file(storeFileProp).exists() -> rootProject.file(storeFileProp)
                    rootProject.file("app/$storeFileProp").exists() -> rootProject.file("app/$storeFileProp")
                    else -> rootProject.file(storeFileProp)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
            } else {
                val fallbackKeystore = file("release-fallback.jks")
                if (!fallbackKeystore.exists()) {
                    try {
                        ProcessBuilder(
                            "keytool", "-genkey", "-v",
                            "-keystore", fallbackKeystore.absolutePath,
                            "-alias", "release",
                            "-keyalg", "RSA",
                            "-keysize", "2048",
                            "-validity", "10000",
                            "-storepass", "android",
                            "-keypass", "android",
                            "-dname", "CN=Release, OU=Mobile, O=Deshi, L=Delhi, S=Delhi, C=IN"
                        ).inheritIO().start().waitFor()
                    } catch (e: Exception) {
                        logger.warn("Could not auto-generate fallback keystore: ${e.message}")
                    }
                }
                keyAlias = "release"
                keyPassword = "android"
                storeFile = fallbackKeystore
                storePassword = "android"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

tasks.matching { it.name.contains("AarMetadata") }.configureEach {
    enabled = false
}
