# Flutter Local Notifications Plugin Keep Rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Preserve Broadcast Receivers and Services
-keep public class * extends android.content.BroadcastReceiver
-keepclassmembers class * extends android.content.BroadcastReceiver {
    <init>(...);
}
-keep public class * extends android.app.Service
-keepclassmembers class * extends android.app.Service {
    <init>(...);
}

# Preserve serialization models
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Timezone and Java 8/17 Desugaring
-keep class net.time4j.** { *; }
-dontwarn net.time4j.**
-keep class java.time.** { *; }
-dontwarn java.time.**

# Keep Flutter Engine plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Suppress Play Store Split / Deferred components warnings (not using play core)
-dontwarn com.google.android.play.core.**
