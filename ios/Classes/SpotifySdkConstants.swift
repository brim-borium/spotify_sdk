//
//  SpotifySdkConstants.swift
//  Pods-Runner
//
//  Created by Steffen Gruschka on 29.11.19.
//

import Foundation

public class SpotfySdkConstants
{
    //connecting
    public static let methodConnectToSpotify = "connectToSpotify"
    public static let methodGetAuthenticationToken = "getAuthenticationToken"
    public static let methodLogoutFromSpotify = "logoutFromSpotify"

    //player api
    public static let methodQueueTrack = "queueTrack"
    public static let methodPlay = "play"
    public static let methodPause = "pause"
    public static let methodResume = "resume"
    public static let methodToggleRepeat = "toggleRepeat"
    public static let methodToggleShuffle = "toggleShuffle"
    public static let methodSkipNext = "skipNext"
    public static let methodSkipPrevious = "skipPrevious"
    public static let methodSeekTo = "seekTo"
    public static let methodSeekToRelativePosition = "seekToRelativePosition"
    public static let methodGetPlayerState = "getPlayerState"

    //user api
    public static let methodAddToLibrary = "addToLibrary"

    //images api
    public static let methodGetImage = "getImage"

    public static let paramClientId = "clientId"
    public static let paramRedirectUrl = "redirectUrl"
    public static let paramSpotifyUri = "spotifyUri"
    public static let paramImageUri = "imageUri"
    public static let paramImageDimension = "imageDimension"
    public static let paramPositionedMilliseconds = "positionedMilliseconds"
    public static let paramRelativeMilliseconds = "relativeMilliseconds"
    public static let paramAccessToken = "accessToken"
    
}
