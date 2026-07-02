plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vibecut_pro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.vibecut_pro"
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

// تعديل استراتيجية حل المكتبات لضمان عدم البحث عن إصدارات مفقودة
configurations.all {
    resolutionStrategy {
        eachDependency {
            if (requested.group == "com.arthenica" && requested.name.contains("ffmpeg-kit")) {
                useVersion("6.0.3")
                because("استخدام إصدار 6.0.3 المستقر والموجود في المستودعات بدلاً من الإصدارات المفقودة")
            }
        }
        // منع أي مكتبة من جلب نسخ قديمة أو مكسورة
        force("com.arthenica:ffmpeg-kit-full:6.0.3")
    }
}
