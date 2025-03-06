# SDK signature (secret code)
copy your signature from readme.html to appropriate parameter in App.kt

# Smartengines SDK dependency
There are some additional dependencies required for the project
### java library (jar-file)
PATH/libs
### jni library
PATH/jniLib
### engine bundles (config files) 
PATH/assets/data
## Common or separete for each build variant dependencies
### common 
PATH: `app/src/main`
in build.gradle `implementation(fileTree("src/main/libs") { include("*.jar") })`
### separate for each build variant
PATH: `app/src/id` or `app/src/code` or `app/src/doc`
In this case the jar dependency should be set in build.gradle for each build variant
`"idImplementation"  (fileTree(mapOf("dir" to "src/id/libs/",     "include" to listOf("*.jar"))))`
`"codeImplementation"(fileTree(mapOf("dir" to "src/code/libs/",   "include" to listOf("*.jar"))))`
`"docImplementation" (fileTree(mapOf("dir" to "src/doc/libs/",    "include" to listOf("*.jar"))))`


# Packages description

## SDK level 
### com.smartengines.common
Common SDK classes (used by another SDK packages)
### com.smartengines.id / com.smartengines.code / com.smartengines.doc
ID/Code/Doc-engine classes

## App level 
### com.smartengines.kotlin_sample
The application logic implementation
### com.smartengines.kotlin_sample.targets
The SessionTarget implementations. Each target defines session settings when session is creating

## Core level
Don't depend on the app logic, so can be used in another projects
### com.smartengines.core.engine
The business-logic implementation. Independent on SDK
### com.smartengines.core.engine.id / com.smartengines.core.engine.code / com.smartengines.core.engine.doc
ID/Code/Doc-engine, session and result wrappers. Depends on SDK


