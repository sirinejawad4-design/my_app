plugins {
    id("com.android.application")
    // يجب تطبيق إضافة Kotlin هنا قبل إضافة Flutter
    id("kotlin-android")
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration

    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.my_app"
        // بالنسبة لـ FlutterFire، يُفضل التأكد من أن minSdk لا يقل عن 21
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

// أضف كتلة الـ dependencies لتضمن عمل Firebase بشكل مجتمع وبدون مشاكل إصدارات
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
}