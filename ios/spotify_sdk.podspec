#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint spotify_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'spotify_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Unofficial Spotify Flutter SDK.'
  s.description      = <<-DESC
Unofficial Spotify Flutter SDK.
                       DESC
  s.homepage         = 'https://github.com/brim-borium/spotify_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'fdimanidis@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
  s.preserve_paths = 'ios-sdk/SpotifyiOS.framework'
  s.vendored_frameworks = 'ios-sdk/SpotifyiOS.framework'
  s.prepare_command = './prepare-iOS-SDK.sh'
  end
