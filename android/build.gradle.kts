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

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
