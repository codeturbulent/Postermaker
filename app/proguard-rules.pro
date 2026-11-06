# ProGuard Rules for GramPradhan Poster Studio

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Room Database & Entities
-keep class * extends androidx.room.RoomDatabase
-dontwarn androidx.room.paging.**
-keep class com.grampradhan.posterstudio.core.data.model.** { *; }
-keep class com.grampradhan.posterstudio.core.data.db.Converters { *; }

# Google ML Kit Selfie Segmentation
-keep class com.google.mlkit.vision.segmentation.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_segmentation_bundled.** { *; }
-dontwarn com.google.mlkit.vision.**

# Coil 3 Image Pipeline
-keep class coil3.** { *; }
-dontwarn coil3.**

# Google Play In-App Billing
-keep class com.android.billingclient.api.** { *; }

# Compose Runtime Models & Parcelize
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
