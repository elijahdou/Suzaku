# Suzaku

[![CI Status](https://img.shields.io/travis/elijahdou/Suzaku.svg?style=flat)](https://travis-ci.org/elijahdou/Suzaku)
[![Version](https://img.shields.io/badge/pod-0.0.1-blue.svg)](https://cocoapods.org/pods/Suzaku)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://cocoapods.org/pods/Suzaku)


Suzaku is a swift version of the hashed wheel timer.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
Hashed Wheel Timer were used as a base for Kernels and Network stacks, and were described by the freebsd, linux people, researchers and in many other searches. Suzaku is a swift implementation of hashed wheel timer designed for iOS clients, suitable for scenarios such as live rooms and persistent connections.

```swift
/// normal
class SomeClass {
    let timer = try! HashedWheelTimer(tickDuration: .seconds(1), ticksPerWheel: 8, dispatchQueue: nil)
    var counter = 0
    let dateFormatter = DateFormatter()
    func someFunction() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        timer.resume()
        _ = try? timer.addTimeout(timeInterval: .seconds(3), reapting: true) { [weak self] in
            guard let self = self else { return }
            self.counter += 1
            print("counter: \(self.counter), \(self.dateFormatter.string(from: Date()))")
        }
    }
}

/// local variable timer
class SomeClass {
    let dateFormatter = DateFormatter()
    
    func someFunction() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        var localTimer: HashedWheelTimer? = try! HashedWheelTimer(tickDuration: .seconds(1), ticksPerWheel: 1, dispatchQueue: nil)
        localTimer?.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            _ = try? localTimer?.addTimeout(timeInterval: .seconds(5), reapting: true) { [weak self] in
                guard let self = self else { return }
                print("fired \(self.dateFormatter.string(from: Date()))")
                localTimer?.stop()
                localTimer = nil
            }
        }
    }
}
```

## Requirements
- iOS 10.0+
- Swift  5.0+
- Xcode 11+

## Installation

### CocoaPods
Suzaku is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Suzaku'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/elijahdou/Suzaku.git")
]
```

## Author

elijahdou, elijahdou@gmail.com

## License

Suzaku is available under the Apache 2.0 license. See the [LICENSE](https://github.com/elijahdou/Suzaku/blob/master/LICENSE) file for more info.
