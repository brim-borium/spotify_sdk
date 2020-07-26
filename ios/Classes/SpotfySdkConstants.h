#ifndef SpotfySdkConstants_h
#define SpotfySdkConstants_h

//connecting
#define methodConnectToSpotify @"connectToSpotify"
#define methodGetAuthenticationToken @"getAuthenticationToken"
#define methodLogoutFromSpotify @"logoutFromSpotify"

 //player api
#define methodQueueTrack @"queueTrack"
#define methodPlay @"play"
#define methodPause @"pause"
#define methodResume @"resume"
#define methodToggleRepeat @"toggleRepeat"
#define methodToggleShuffle @"toggleShuffle"
#define methodSkipNext @"skipNext"
#define methodSkipPrevious @"skipPrevious"
#define methodSeekTo @"seekTo"
#define methodSeekToRelativePosition @"seekToRelativePosition"

 //user api
#define methodAddToLibrary @"addToLibrary"

 //images api
#define methodGetImage @"getImage"

#define paramClientId @"clientId"
#define paramRedirectUrl @"redirectUrl"
#define paramSpotifyUri @"spotifyUri"
#define paramImageUri @"imageUri"
#define paramImageDimension @"imageDimension"
#define paramPositionedMilliseconds @"positionedMilliseconds"
#define paramRelativeMilliseconds @"relativeMilliseconds"

#endif /* SpotfySdkConstants_h */
