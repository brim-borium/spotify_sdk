import java.net.URL
import java.net.URI
import java.net.HttpURLConnection

plugins {
    id("com.android.library")
}

group = "de.minimalme.spotify_sdk"
version = "1.0-SNAPSHOT"

val spotifyAarVersion = "0.8.0"
val spotifyAarTag = "v0.8.0-appremote_v2.1.0-auth"
val aarFileName = "spotify-app-remote-release-$spotifyAarVersion.aar"
val aarUrl = "https://github.com/spotify/android-sdk/releases/download/$spotifyAarTag/$aarFileName"

val repoDir = file("$projectDir/m2repository")
val artifactDir = file("m2repository/com/spotify/android/spotify-app-remote/$spotifyAarVersion")
val aarDestFile = File(artifactDir, "spotify-app-remote-$spotifyAarVersion.aar")
val pomDestFile = File(artifactDir, "spotify-app-remote-$spotifyAarVersion.pom")

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://jitpack.io") }
    maven { url = uri(repoDir) }
}

try {
    rootProject.allprojects {
        repositories {
            maven {
                url = uri(repoDir)
            }
        }
    }
} catch (e: Exception) {
    // Fallback for standalone builds or isolated project evaluations
}

fun ensureSpotifyAarDownloaded() {
    if (aarDestFile.exists() && pomDestFile.exists()) {
        return
    }
    artifactDir.mkdirs()
    println("Downloading Spotify App Remote SDK from $aarUrl...")
    try {
        var currentUrl = URI.create(aarUrl).toURL()
        var connection = currentUrl.openConnection() as HttpURLConnection
        connection.connectTimeout = 15000
        connection.readTimeout = 30000
        var status = connection.responseCode
        var redirectCount = 0
        while (status == HttpURLConnection.HTTP_MOVED_TEMP ||
               status == HttpURLConnection.HTTP_MOVED_PERM ||
               status == HttpURLConnection.HTTP_SEE_OTHER ||
               status == 307 || status == 308) {
            if (redirectCount > 5) {
                throw GradleException("Too many redirects while downloading Spotify App Remote SDK")
            }
            val newUrl = connection.getHeaderField("Location")
            currentUrl = URI.create(newUrl).toURL()
            connection = currentUrl.openConnection() as HttpURLConnection
            connection.connectTimeout = 15000
            connection.readTimeout = 30000
            status = connection.responseCode
            redirectCount++
        }
        if (status == HttpURLConnection.HTTP_OK) {
            connection.inputStream.use { input ->
                aarDestFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            println("Downloaded Spotify App Remote SDK successfully to ${aarDestFile.absolutePath}")
            
            pomDestFile.writeText("""
                <?xml version="1.0" encoding="UTF-8"?>
                <project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                  <modelVersion>4.0.0</modelVersion>
                  <groupId>com.spotify.android</groupId>
                  <artifactId>spotify-app-remote</artifactId>
                  <version>$spotifyAarVersion</version>
                  <packaging>aar</packaging>
                </project>
            """.trimIndent())
        } else {
            throw GradleException("Server returned HTTP $status when downloading $aarUrl")
        }
    } catch (e: Exception) {
        throw GradleException("Failed to download Spotify App Remote SDK: ${e.message}. Please check your internet connection.", e)
    }
}

// Ensure AAR exists for repository resolution
ensureSpotifyAarDownloaded()

android {
    namespace = "de.minimalme.spotify_sdk"
    compileSdk = 36

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
        consumerProguardFiles("consumer-rules.pro")
    }

    lint {
        disable.add("InvalidPackage")
    }
}

dependencies {
    implementation("com.spotify.android:auth:5.0.0")
    implementation("com.spotify.android:spotify-app-remote:$spotifyAarVersion")
    implementation("com.fasterxml.jackson.core:jackson-annotations:2.22")
    implementation("com.google.code.gson:gson:2.14.0")
    implementation("com.github.stuhlmeier:kotlin-events:v2.0")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

tasks.register("downloadSpotifySdk") {
    group = "verification"
    description = "Verify and download the Spotify App Remote SDK AAR file"
    doLast {
        ensureSpotifyAarDownloaded()
        if (aarDestFile.exists()) {
            println("Spotify App Remote SDK is successfully downloaded and located at: ${aarDestFile.absolutePath}")
        } else {
            throw GradleException("Spotify App Remote SDK download failed or file is missing.")
        }
    }
}
