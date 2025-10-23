# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Camera and media
-keep class androidx.camera.** { *; }
-keep class android.hardware.camera2.** { *; }
-keep class android.media.** { *; }

# Silent camera module
-keep class com.quietcamera.app.SilentCameraModule { *; }
-keepclassmembers class com.quietcamera.app.SilentCameraModule {
    public *;
}

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
