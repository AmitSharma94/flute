import com.android.build.gradle.LibraryExtension
allprojects {
    repositories {
        google()
        mavenCentral()
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
subprojects {
    if (name == "on_audio_query_android") {
        pluginManager.withPlugin("com.android.library") {
            extensions.configure<LibraryExtension> {
                namespace = "com.lucasjosino.on_audio_query"
            }
        }
    }
}