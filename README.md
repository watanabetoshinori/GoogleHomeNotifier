# Google Home Notifier for iOS

Send notifications to Google Home.

This is iOS version of noelportugal/google-home-notifier

- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Google Home Notifier into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

# Add this block
pre_install do |installer|
Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target '<Your Target Name>' do
  use_frameworks!

  # Add this line
  pod 'GoogleHomeNotifier', :git => 'https://github.com/watanabetoshinori/GoogleHomeNotifier.git', :branch => 'master'

end
```

Then, run the following command:

```bash
$ pod install
```

## Usage

```swift
import GoogleHomeNotifier

let notifier = GoogleHomeNotifier()

notifier.deviceName = "Living Room" // Change to your Google Home name

// or if you know your Google Home IP
// notifier.ipAddress = "192.168.1.0"

notifier.notify(message: "Hey Foo") { (error) in
  print(error)
}

```

You can see the sample code from the [Example](https://github.com/watanabetoshinori/GoogleHomeNotifier/tree/master/Example) directory.

## License

Google Home Notifier is released under the MIT license. [See LICENSE](https://github.com/watanabetoshinori/GoogleHomeNotifier/blob/master/LICENSE) for details.
