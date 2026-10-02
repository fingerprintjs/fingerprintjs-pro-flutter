# Stopgap for gaps in Fingerprint Android SDK 4.1.x consumer rules. Remove once the SDK ships them.
# https://developer.android.com/build/shrink-code#configuration-files

# The SDK references Play Services location without depending on it. R8 fails with "Missing class".
-dontwarn com.google.android.gms.location.**,com.google.android.gms.tasks.**

# The SDK keeps only some parts of Kotlin multifile facades. R8 9.1 moves the others out of their
# package, and the app crashes on startup with IllegalAccessError.
-keeppackagenames kotlin,kotlin.**
