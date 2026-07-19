# R8/ProGuard rules for spotify_sdk_android
# Suppress warnings about missing transitive dependencies referenced by Spotify App Remote SDK
-dontwarn com.fasterxml.jackson.databind.deser.std.StdDeserializer
-dontwarn com.fasterxml.jackson.databind.ser.std.StdSerializer
-dontwarn com.spotify.base.annotations.NotNull
-dontwarn javax.annotation.Nonnull
-dontwarn javax.annotation.Nullable
