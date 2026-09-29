// الملف الجاهز: android/build.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
        // مستودع JitPack للمكتبات المخصصة
        maven { url = uri("https://jitpack.io") }
        // مستودع Maven الرئيسي لضمان العثور على حزم FFmpeg
        maven { url = uri("https://repo.maven.apache.org/maven2") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// رفع compileSdk لمكتبات الإضافات (مثل file_picker) إلى 36
// لأن flutter_plugin_android_lifecycle تتطلب 36 أو أحدث. لا يغيّر minSdk ولا targetSdk.
subprojects {
    val raiseCompileSdk: Project.() -> Unit = {
        extensions
            .findByType(com.android.build.api.dsl.LibraryExtension::class.java)
            ?.let { it.compileSdk = 36 }
    }
    if (state.executed) {
        raiseCompileSdk()
    } else {
        afterEvaluate { raiseCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
