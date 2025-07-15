import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 기존 key.properties 파일 읽는 부분 (수정 없음)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// ✅ 1. .env 파일을 읽기 위한 설정 추가 (코틀린 문법)
val envProperties = Properties()
val envFile = rootProject.file("../.env")
if (envFile.exists()) {
    envProperties.load(FileInputStream(envFile))
}

android {
    namespace = "com.enryu11.jeonmattaeng"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.enryu11.jeonmattaeng"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ 2. .env 파일의 변수를 manifestPlaceholders에 등록 (코틀린 문법)
        // API 키가 없으면 빌드가 실패하도록 하여 실수를 방지합니다.
        manifestPlaceholders["Maps_API_KEY"] = envProperties.getProperty("Maps_API_KEY")
            ?: error("Maps_API_KEY not found in .env file")
    }

    // 기존 signingConfigs 부분 (수정 없음)
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    // 기존 buildTypes 부분 (수정 없음)
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // 기존 compileOptions 부분 (수정 없음)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // 기존 kotlinOptions 부분 (수정 없음)
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}

// ✅ 3. Flutter 의존성 추가 (보통 기본으로 포함되어 있음)
dependencies {
    // 필요한 경우 여기에 다른 의존성을 추가할 수 있습니다.
}