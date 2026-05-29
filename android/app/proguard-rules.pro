# Flutter Local Notifications - keep Gson TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }

# Keep Flutter Local Notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep NotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep generic type info for R8
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
