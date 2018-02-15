Pod::Spec.new do |s|
  s.name = "GoogleHomeNotifier"
  s.version = "1.0.0"
  s.license = "MIT"
  s.summary = "Google Home Notification for iOS"
  s.author = "Toshinori Watanabe"
  s.homepage = "https://github.com/watanabetoshinori/GoogleHomeNotifier"
  s.source = { :git => "git@github.com:watanabetoshinori/GoogleHomeNotifier.git", :tag => s.version }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/*.{h,swift}'
  s.resources = 'Resources/*.{xib,storyboard}', 'Resources/*.xcassets'

  s.dependency 'google-cast-sdk', '2.10.4'

  s.frameworks = [
    "GoogleCast",
    "Accelerate",
    "AudioToolbox",
    "AVFoundation",
    "CFNetwork",
    "CoreBluetooth",
    "CoreText",
    "MediaPlayer",
    "Security",
    "SystemConfiguration"
  ]

  s.libraries = 'c++'

  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/google-cast-sdk/GoogleCastSDK-2.10.4-Release'   
  }

end
