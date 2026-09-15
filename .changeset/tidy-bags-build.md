---
"fingerprintjs-pro-flutter": patch
---

Migrate the Android plugin and example app to AGP 9.0.1 built-in Kotlin while preserving Java 11 bytecode compatibility. The plugin no longer applies the Kotlin Gradle plugin itself, so it builds under AGP 9, where applying it is an error. Apps still on AGP 8 keep working as long as their Kotlin Gradle plugin is 2.2.20 or newer, which the v5 native Android SDK requires anyway.
