plugins {
    id("com.android.library")
    id("kotlin-android")
}

group = "de.minimalme.spotify_sdk"
version = "1.0-SNAPSHOT"

android {
    namespace = "de.minimalme.spotify_sdk"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        minSdk = 21
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    lint {
        disable.add("InvalidPackage")
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.2.20")
    implementation("com.spotify.android:auth:5.0.0")
    implementation(project(":spotify-app-remote"))
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("com.github.stuhlmeier:kotlin-events:v2.0")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
