# FlutterFire App Check still contains an optional SafetyNet provider branch.
# The app activates Play Integrity instead, and SafetyNet is excluded from
# release builds to avoid packaging the deprecated Play Services SDK.
-dontwarn com.google.firebase.appcheck.safetynet.SafetyNetAppCheckProviderFactory
