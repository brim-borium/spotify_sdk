allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

rootProject.layout.buildDirectory.set(rootProject.rootDir.resolve("../build"))

subprojects {
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.map { it.dir(project.name) })
}
subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
