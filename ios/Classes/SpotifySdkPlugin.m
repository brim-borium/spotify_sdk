#import "SpotifySdkPlugin.h"
#import <SpotifyiOS/SpotifyiOS.h>
#import "ConnectionStatusHandler.h"
#import "SpotfySdkConstants.h"

@implementation SpotifySdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"spotify_sdk"
                                     binaryMessenger:[registrar messenger]];
    FlutterEventChannel* connectionStatusChannel = [FlutterEventChannel eventChannelWithName:@"connection_status_subscription" binaryMessenger:registrar.messenger];

    SpotifySdkPlugin* instance = [[SpotifySdkPlugin alloc] init];

    [registrar addMethodCallDelegate:instance channel:channel];
    [connectionStatusChannel setStreamHandler:[[ConnectionStatusHandler alloc] init]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    //    [SPTAppRemote checkIfSpotifyAppIsActive:^(BOOL active) {
    //        if (active) {
    //            NSLog(@"Spotify is active");
    //        } else {
    //            NSLog(@"Spotify is active...pause...NOT");
    //        }
    //    }];

    NSDictionary* _arguments = call.arguments;

    if ([methodConnectToSpotify isEqualToString:call.method]) {
        NSString* clientID = [_arguments objectForKey:@"clientId"];
        NSString* url = [_arguments objectForKey:@"redirectUrl"];
        [self connectToSpotify:clientID redirectURL:url];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)connectToSpotify:(NSString*) clientId redirectURL:(NSString*)redirectURL {
//        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    NSLog(@"ClientID: %@, RedirectURL: %@", clientId, redirectURL);
}

@end
