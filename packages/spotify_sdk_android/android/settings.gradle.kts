pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://jitpack.io") }
    }
}

plugins {
    id("com.android.library") version "9.3.1" apply false
    id("org.jetbrains.kotlin.android") version "2.4.10" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

rootProject.name = "spotify_sdk"
