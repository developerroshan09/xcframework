import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    id("maven-publish")
}

kotlin {
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }

        // Enable publishing for Android
        publishLibraryVariants("release", "debug")
    }

    val xcframeworkName = "ComposeApp"
    val xcf = XCFramework(xcframeworkName)

    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = xcframeworkName
            isStatic = true
            xcf.add(this)
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            implementation(compose.ui)
            implementation(compose.components.resources)
            implementation(compose.components.uiToolingPreview)
            implementation(libs.androidx.lifecycle.viewmodelCompose)
            implementation(libs.androidx.lifecycle.runtimeCompose)
        }
        androidMain.dependencies {
            implementation(compose.preview)
            implementation(libs.androidx.activity.compose)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "com.xcframework.test"
    compileSdk = libs.versions.android.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    debugImplementation(compose.uiTooling)
}

// Publishing configuration
publishing {
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/developerroshan09/xcframework")
            credentials {
                username = System.getenv("GITHUB_USERNAME") ?: ""
                password = System.getenv("GITHUB_TOKEN") ?: ""
            }
        }
    }

    publications {
        withType<MavenPublication> {
            groupId = "com.developerroshan"
            version = "1.1.0"

            pom {
                name.set("ComposeApp")
                description.set("Kotlin Multiplatform Compose library")
                url.set("https://github.com/developerroshan09/xcframework")

                licenses {
                    license {
                        name.set("MIT License")
                        url.set("https://opensource.org/licenses/MIT")
                    }
                }

                developers {
                    developer {
                        id.set("developerroshan09")
                        name.set("Roshan Bade")
                    }
                }

                scm {
                    connection.set("scm:git:git://github.com/developerroshan09/xcframework.git")
                    developerConnection.set("scm:git:ssh://github.com/developerroshan09/xcframework.git")
                    url.set("https://github.com/developerroshan09/xcframework")
                }
            }
        }

        // Filter out iOS publications - they should use XCFramework/SPM instead
        matching { it.name.contains("ios", ignoreCase = true) }.all {
            // Don't publish iOS targets to Maven
            tasks.withType<PublishToMavenRepository>().matching {
                it.publication == this
            }.configureEach {
                enabled = false
            }
        }
    }
}