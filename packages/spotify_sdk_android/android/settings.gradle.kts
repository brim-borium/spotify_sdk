pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://jitpack.io") }
    }
}

plugins {
    id("com.android.library") version "8.11.2" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

rootProject.name = "spotify_sdk"
