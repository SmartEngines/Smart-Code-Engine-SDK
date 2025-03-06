//  Copyright (c) 2016-2024, Smart Engines Service LLC
//  All rights reserved.

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.jetbrains.kotlin.android)
}

android {
    namespace = "com.smartengines.kotlin_sample"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.smartengines.kotlin_sample"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    flavorDimensions += "engine"
    productFlavors {
        create("id"){// limited functionality for public usage
            dimension = "engine"
            applicationIdSuffix = ".id"
        }
        create("code"){// all new features for private usage
            dimension = "engine"
            applicationIdSuffix = ".code"
        }
        create("doc"){// limited functionality for public usage
            dimension = "engine"
            applicationIdSuffix = ".doc"
        }
        create("text"){
            dimension = "engine"
            applicationIdSuffix = ".text"
        }
    }


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.1"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)

    // Smartengines SDK library
    implementation(fileTree("src/main/libs") { include("*.jar") })
    // Sample of separate SDK libs for each build variant
    //    "idImplementation"  (fileTree(mapOf("dir" to "src/id/libs/",     "include" to listOf("*.jar"))))
    //    "codeImplementation"(fileTree(mapOf("dir" to "src/code/libs/",   "include" to listOf("*.jar"))))
    //    "docImplementation" (fileTree(mapOf("dir" to "src/doc/libs/",    "include" to listOf("*.jar"))))

    // CameraX core library using the camera2 implementation
    implementation(libs.androidx.camera.camera2)
    // If you want to additionally use the CameraX Lifecycle library
    implementation(libs.androidx.camera.lifecycle)
    // If you want to additionally use the CameraX VideoCapture library
    implementation(libs.androidx.camera.video)
    // If you want to additionally use the CameraX View class
    implementation(libs.androidx.camera.view)
    // If you want to additionally add CameraX ML Kit Vision Integration
    implementation(libs.androidx.camera.mlkit.vision)
    // If you want to additionally use the CameraX Extensions library
    implementation(libs.androidx.camera.extensions)

    // ACCOMPANIST
    implementation(libs.accompanist.permissions)
    // nfc libs
    implementation("org.jmrtd:jmrtd:0.7.18")
    implementation("net.sf.scuba:scuba-sc-android:0.0.18")


    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.ui.tooling)
    debugImplementation(libs.androidx.ui.test.manifest)
}