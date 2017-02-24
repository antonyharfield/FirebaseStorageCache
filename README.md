# FirebaseStorageCache
FIRStorage for iOS with caching and offline capabilities

[![CI Status](http://img.shields.io/travis/antonyharfield/FirebaseStorageCache.svg?style=flat)](https://travis-ci.org/antonyharfield/FirebaseStorageCache)
[![Version](https://img.shields.io/cocoapods/v/FirebaseStorageCache.svg?style=flat)](http://cocoapods.org/pods/FirebaseStorageCache)
[![License](https://img.shields.io/cocoapods/l/FirebaseStorageCache.svg?style=flat)](http://cocoapods.org/pods/FirebaseStorageCache)
[![Platform](https://img.shields.io/cocoapods/p/FirebaseStorageCache.svg?style=flat)](http://cocoapods.org/pods/FirebaseStorageCache)

## Demo

Clone/download [FirebaseOfflineAppDemo](https://github.com/antonyharfield/FirebaseOfflineAppDemo) and run `pod install` before pressing play in Xcode. The demo contains 3 examples: no caching, NSCache and FirebaseStorageCache.

## Requirements

This project assumes that you have already [setup Firebase for iOS](https://firebase.google.com/docs/ios/setup).

## Installation

FirebaseStorageCache is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FirebaseStorageCache'
```

## Usage

### Use the default shared cache

```swift
let ref: FIRStorageReference = ...
FirebaseStorageCache.main.get(storageReference: ref) { data in
  // do something with your file
}
```

### Create custom storage caches

```swift
let oneWeekDiskCache = DiskCache(name: "customCache", cacheDuration: 60 * 60 * 24 * 7)
let firStorageCache = FirebaseStorageCache(cache: oneWeekDiskCache)
firStorageCache.get(storageReference: ref) { data in
  // do something with your file
}
```

### Extension for loading images (in UIImageView)

```swift
imageView.setImage(storageReference: ref)
```

### Extension for loading web pages (in UIWebView and WKWebView)

Simple:

```swift
webView.loadHTML(storageReference: ref)
```

With post processing on the HTML:

```swift
let styleHTML: (Data) -> Data = { data in
            let pre = "<style>body {margin: 16px}</style>"
            var preData = pre.data(using: .utf8) ?? Data()
            preData.append(data)
            return preData
        }
webView.loadHTML(storageReference: ref, postProcess: styleHTML)
```

### Cleaning/pruning the cache

In the `didFinishLaunchingWithOptions` of your AppDelegate, you should call the `prune()` 
method of your disk caches to remove any old files:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        FirebaseStorageCache.main.prune()
        return true
    }
```

## Author

Antony Harfield, antonyharfield@gmail.com

## License

FirebaseStorageCache is available under the MIT license. See the LICENSE file for more info.
