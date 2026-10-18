# Flutter engine & plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# UCrop (Image Cropper Android)
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# Material & AndroidX
-keep class com.google.android.material.** { *; }
-dontwarn com.google.android.material.**

# Serialization & Reflection models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
