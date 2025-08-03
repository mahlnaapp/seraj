buildscript {
    ext.kotlin_version = '1.9.22' // **** تم تحديث إصدار Kotlin ****
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.4.0' // **** تم تحديث إصدار Gradle Plugin ****
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file('../build')

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}