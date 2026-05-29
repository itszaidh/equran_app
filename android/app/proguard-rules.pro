# Flutter engine — required for R8 compatibility
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter JNI interface
-keep class io.flutter.view.** { *; }

# App widget receivers (home_widget / Glance)
-keep class com.app.equran.PrayerTimesWidgetReceiver { *; }
-keep class com.app.equran.NextPrayerWidgetReceiver { *; }
-keep class com.app.equran.BootReceiver { *; }

# AudioService (just_audio_background)
-keep class com.ryanheise.audioservice.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# WorkManager
-keep class androidx.work.** { *; }

# Geolocator
-dontwarn com.google.android.gms.**

# Keep annotations used by various plugins
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
