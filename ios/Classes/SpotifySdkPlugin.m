#import "SpotifySdkPlugin.h"
#if __has_include(<spotify_sdk/spotify_sdk-Swift.h>)
#import <spotify_sdk/spotify_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "spotify_sdk-Swift.h"
#endif

#import <SpotifyiOS/SpotifyiOS.h>

@implementation SpotifySdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSpotifySdkPlugin registerWithRegistrar:registrar];
    
}
@end
