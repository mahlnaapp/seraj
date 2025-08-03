buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.0") // إصدار Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22") // إصدار Kotlin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File(rootProject.projectDir, "../build")

subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
}

tasks.register("clean", org.gradle.api.tasks.Delete::class) {
    delete(rootProject.buildDir)
}