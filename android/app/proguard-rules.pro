# Flutter engine & plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# UCrop (Image Cropper Android) & OkHttp
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Gal & Native Media Storage
-keep class io.github.amery24.gal.** { *; }
-dontwarn io.github.amery24.gal.**

# Material & AndroidX
-keep class com.google.android.material.** { *; }
-dontwarn com.google.android.material.**

# Serialization & Reflection models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# General warning suppression for optional 3rd-party dependencies
-dontwarn **
