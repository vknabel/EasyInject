[![CocoaPods](https://img.shields.io/cocoapods/v/EasyInject.svg?maxAge=2592000?style=flat-square)]()
[![CocoaPods](https://img.shields.io/cocoapods/p/EasyInject.svg?maxAge=2592000?style=flat-square)]()
[![Install](https://img.shields.io/badge/install-SwiftPM%20%7C%20Carthage%20%7C%20Cocoapods-lightgrey.svg?style=flat-square)]()
[![License](https://img.shields.io/cocoapods/l/EasyInject.svg?maxAge=2592000?style=flat-square)]()

# EasyInject
EasyInject is designed to be an easy to use, lightweight composition and dependency injection library.
Instead of injecting instances for specific types, you provide instances for keys, without losing any type information. This enables its `Injector`s to be used as a composable, dynamic and typesafe data structure. It may be comparable with a Dictionary that may contain several types, without losing type safety.

Check out the generated docs at [vknabel.github.io/EasyInject](https://vknabel.github.io/EasyInject/).

## Installation
EasyInject is a Swift only project and supports [Swift Package Manager](https://github.com/apple/swift-package-manager), [Carthage](https://github.com/Carthage/Carthage) and [CocoaPods](https://github.com/CocoaPods/CocoaPods).

### Swift Package Manager

```swift
import PackageDescription

let package = Package(
    name: "YourPackage",
    dependencies: [
        .Package(url: "https://github.com/vknabel/EasyInject.git", majorVersion: 0, minor: 6)
    ]
)
```

### Carthage

```ruby
github "vknabel/EasyInject" ~> 0.6
```

### CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'EasyInject', '~> 0.6'
```

## Introduction
In order to inject your dependencies, you first need to prepare your key by implementing `Hashable`.

```swift
import EasyInject

// As all `String`s are `Hashable`, there's nothing to do here
```

Now we need to define our keys, by setting up `Provider`s with `String`s and our type hints.

```swift
extension Provider {
    static var baseUrl: Provider<String, String> {
        return Provider<String, String>(for: "baseUrl")
    }
    static var networkService: Provider<String, NetworkService> {
        // produces a key of `networkService(...) -> Network`.
        return .derive()
    }
    static var dataManager: Provider<String, DataManager> {
        return .derive()
    }
}
```

Every type that may be provided, needs to be declared as `Providable`.

```swift
extension String: Providable { }

final class NetworkService: Providable {
    let baseUrl: String
    init<I: Injector where I.Key == String>(injector: inout I) throws {
        print("Start: NetworkService")
        baseUrl = try injector.resolving(from: .baseUrl)
        print("Finish: NetworkService")
    }
}
final class DataManager: Providable {
    let networkService: NetworkService
    init<I: Injector where I.Key == String>(injector: inout I) throws {
        print("Start: DataManager")
        networkService = try injector.resolving(from: .networkService)
        print("Finish: DataManager")
    }
}
```

### LazyInjector
There are some `Injector`s to choose, like a `StrictInjector` or `LazyInjector`.
Let's pick the lazy one first and provide some values for our keys.

```swift
var lazyInjector = LazyInjector<String>()
lazyInjector.provide(for: .baseUrl, usingFactory: { _ in
    print("Return: BasUrl")
    return "https://my.base.url/"
})
lazyInjector.provide(for: .dataManager, usingFactory: DataManager.init)
lazyInjector.provide(for: .networkService, usingFactory: NetworkService.init)
```

Since we are using the `LazyInjector`, no closure we passed has been executed yet.
They will only be executed when they get resolved.

```swift
// this will execute all factories we passed for our providers
do {
    try lazyInjector.resolve(from: .dataManager)
} catch {
    print("Error: \(error)")
}
```

Because we picked `LazyInjector`, all dependencies will be resolved automatically, when needed. Therefore the produced output would be:
```
Start: DataManager
Start: NetworkService
Return: BasUrl
Finish: NetworkService
Finish: DataManager
```

So because of the laziness of out `LazyInjector`, all dependencies will be resolved automatically.

> Currently cyclic dependencies will result in endless recursion.


### StrictInjector
The previous example would fail when using `StrictInjector`, because we provided `.dataManager` before providing `.networkService`, but `DataManager` requires a `.networkService`.

```swift
var strictInjector = StrictInjector<String>()
strictInjector.provide(for: .baseUrl, usingFactory: { _ in
    print("Return: BaseUrl")
    return "https://my.base.url/"
})
strictInjector.provide(for: .dataManager, usingFactory: DataManager.init) // <-- missing .networkService
strictInjector.provide(for: .networkService, usingFactory: NetworkService.init)
do {
    try strictInjector.resolve(from: .dataManager)
} catch {
    print("Error: \(error)")
}
```

The output would be:
```
Return: BaseUrl
Start: DataManager
Start: NetworkService
Finish: NetworkService
Error: keyNotProvided("networkService(...) -> NetworkService")
```

This behavior may be helpful when debugging your `LazyInjector` in order to detect dependency cycles.

You may fix this error, just by flipping the lines with `.networkService` and `.dataManager`, and that would lead to the following output:
```
Return: BaseUrl
Start: NetworkService
Finish: NetworkService
Start: DataManager
Finish: DataManager
```

```swift
strictInjector = StrictInjector<String>()
strictInjector.provide(for: .baseUrl, usingFactory: { _ in
    print("Return: BaseUrl")
    return "https://my.base.url/"
})
strictInjector.provide(for: .networkService, usingFactory: NetworkService.init)
strictInjector.provide(for: .dataManager, usingFactory: DataManager.init)
do {
    try strictInjector.resolve(from: .dataManager)
} catch {
    print("Error: \(error)")
}
```

### GlobalInjector
A `GobalInjector` wraps another `Injector` in order to make it act like a class.

```swift
let globalInjector = GlobalInjector(injector: strictInjector)
let second = globalInjector
// `globalInjector` may be mutated as it is a class.
second.provide("https://vknabel.github.io/EasyInject", for: .baseUrl)

if let left = try? globalInjector.resolve(from: .baseUrl),
let right = try? globalInjector.resolve(from: .baseUrl),
left == right {
// both `right` and `left` contain `"https://vknabel.github.io/EasyInject"` for `.baseUrl` due to reference semantics
}
```

### ComposedInjector
A `ComposedInjector` consists of two other `Injector`s.
The call `.resolve(from:)` will target the `.left` `Injector` and on failure, the `.right` one.
`.provide(for:,usingFactory:)` defaults to `.provideLeft(for:,usingFactory:)` which will provide the factory only to the `.left` one.
 
Usually the left `Injector` will be the local one, whereas the right one is a global one. This makes it possible to cascade `ComposedInjector`s from your root controller down to your leaf controllers.

```swift
var composedInjector = ComposedInjector(left: StrictInjector(), right: globalInjector)
composedInjector.provideLeft("https://vknabel.github.io/EasyInject/Structs/ComposedInjector.html", for: .baseUrl)
do {
    try composedInjector.resolveBoth(from: .baseUrl)
		// returns `("https://vknabel.github.io/EasyInject/Structs/ComposedInjector.html", "https://vknabel.github.io/EasyInject")`
} catch {
    print("Error: \(error)")
}
```

## Author

Valentin Knabel, develop@vknabel.com

## License

EasyInject is available under the MIT license. See the LICENSE file for more info.
