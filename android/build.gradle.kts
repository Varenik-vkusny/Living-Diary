plugins {
    id("com.android.application").apply(false)
    id("org.jetbrains.kotlin.android").apply(false)
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Добавляем зависимость для плагина Google Services
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File(project.rootDir, "../build")
subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}






allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val kotlin_version by extra("1.9.23")

