#import "SpotifySdkPlugin.h"
#import "ConnectionStatusHandler.h"
#import "SpotfySdkConstants.h"
#import <SpotifyiOS/SpotifyiOS.h>

@interface SpotifySdkPlugin()

@property (nonatomic) SPTSessionManager *sessionManager;
@property (nonatomic) SPTAppRemote *appRemote;

@end

@implementation SpotifySdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"spotify_sdk"
                                     binaryMessenger:[registrar messenger]];
    FlutterEventChannel *connectionStatusChannel = [FlutterEventChannel eventChannelWithName:@"connection_status_subscription" binaryMessenger:registrar.messenger];

    SpotifySdkPlugin *instance = [[SpotifySdkPlugin alloc] init];
    [registrar addApplicationDelegate:instance];

    [registrar addMethodCallDelegate:instance channel:channel];
    [connectionStatusChannel setStreamHandler:[[ConnectionStatusHandler alloc] init]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *_arguments = call.arguments;

    if ([methodConnectToSpotify isEqualToString:call.method]) {
        NSString *clientID = [_arguments objectForKey:@"clientId"];
        NSString *url = [_arguments objectForKey:@"redirectUrl"];
        [self connectToSpotify:clientID redirectURL:url];
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)connectToSpotify:(NSString*) clientId redirectURL:(NSString*)redirectURL {
    SPTConfiguration *configuration =
    [[SPTConfiguration alloc] initWithClientID:clientId redirectURL:[NSURL URLWithString:redirectURL]];

    self.appRemote = [[SPTAppRemote alloc] initWithConfiguration:configuration logLevel:SPTAppRemoteLogLevelNone];

    // Note: A blank string will play the user's last song or pick a random one.
    BOOL spotifyInstalled = [self.appRemote authorizeAndPlayURI:@""];
    if (!spotifyInstalled) {
        /*
         * The Spotify app is not installed.
         * Use SKStoreProductViewController with [SPTAppRemote spotifyItunesItemIdentifier] to present the user
         * with a way to install the Spotify app.
         */
    }
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options: (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [self setAccessTokenFromURL:url];
    return YES;
}

- (void)setAccessTokenFromURL:(NSURL *)url {
    NSDictionary *params = [self.appRemote authorizationParametersFromURL:url];
    NSString *token = params[SPTAppRemoteAccessTokenKey];
    if (token) {
        self.appRemote.connectionParameters.accessToken = token;
    } else if (params[SPTAppRemoteErrorDescriptionKey]) {
//        NSLog(@"%@", params[SPTAppRemoteErrorDescriptionKey]);
    }
}

@end
