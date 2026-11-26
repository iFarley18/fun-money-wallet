# Plaid Link SDK pulls in WorkManager/Room; R8 strips Room's generated
# database constructors in release builds, crashing at startup.
-keep class * extends androidx.room.RoomDatabase { <init>(...); }
-keep class androidx.work.impl.** { *; }
-keep class com.plaid.** { *; }
-dontwarn com.plaid.**
