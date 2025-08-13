plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_hub"
    compileSdk = flutter.compileSdkVersion // Thường là 34 hoặc 33 cho Flutter
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11 // Sửa cú pháp, thêm dấu "="
        targetCompatibility = JavaVersion.VERSION_11 // Sửa cú pháp, thêm dấu "="
    }

    kotlinOptions {
        jvmTarget = "11" // Đơn giản hóa, không cần toString()
    }

    defaultConfig {
        applicationId = "com.example.project_hub"
        minSdk = flutter.minSdkVersion // Thường là 21 hoặc cao hơn
        targetSdk = flutter.targetSdkVersion // Thường là 34 hoặc 33
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Giữ nguyên để chạy debug
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}