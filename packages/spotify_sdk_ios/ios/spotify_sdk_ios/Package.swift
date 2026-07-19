// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spotify_sdk_ios",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "spotify-sdk-ios", targets: ["spotify_sdk_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "spotify_sdk_ios",
            dependencies: [
                "SpotifyiOS"
            ],
            path: "Classes"
        ),
        .binaryTarget(
            name: "SpotifyiOS",
            path: "ios-sdk/SpotifyiOS.xcframework"
        )
    ]
)
