/*:
 # EasyInject
 EasyInject is designed to be an easy to use, lightweight dependency injection library.
 Instead of injecting instances for specific types, you provide instances for keys, without losing any type information.

 ## Installation
 EasyInject supports [Swift Package Manager](https://github.com/apple/swift-package-manager), [Carthage](https://github.com/Carthage/Carthage) and [CocoaPods](https://github.com/CocoaPods/CocoaPods).

 ### Swift Package Manager

 ```swift
 import PackageDescription

 let package = Package(
	name: "YourPackage",
	dependencies: [
 .Package(url: "https://github.com/vknabel/EasyInject.git", majorVersion: 0, minor: 1)
	]
 )
 ```
 
 ### Carthage

 ```ruby
 github "vknabel/EasyInject" ~> 0.1
 ```
 
 ### CocoaPods

 ```ruby
 source 'https://github.com/CocoaPods/Specs.git'
 use_frameworks!

 pod 'EasyInject', '~> 0.1'
 ```

 ## Introduction
 In order to inject your dependencies, you first need to prepare your key by implementing `ProvidableKey`.
 */

import EasyInject

extension String: ProvidableKey {
    // As all `String`s are `Hashable`, there's nothing to do here
}

/*:
 Now we need to define our keys, by setting up `Provider`s with `String`s and our type hints.
 */
extension Provider {
    static var baseUrl: Provider<String, String> {
        return Provider<String, String>(for: "baseUrl")
    }
    static var networkService: Provider<String, NetworkService> {
        return Provider<String, NetworkService>(for: "NetworkService")
    }
    static var dataManager: Provider<String, DataManager> {
        return Provider<String, DataManager>(for: "DataManager")
    }
}

/*:
 Every type that may be provided, needs to be declared as `Providable`.
 */
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

/*:
 ### LazyInjector
 There are some `Injector`s to choose, like a `StrictInjector` or `LazyInjector`.
 Let's pick the lazy one first and provide some values for our keys.
 */

var lazyInjector = LazyInjector<String>()
lazyInjector.provide(for: .baseUrl, usingFactory: { _ in
    print("Return: BaseUrl")
    return "https://my.base.url/"
})
lazyInjector.provide(for: .dataManager, usingFactory: DataManager.init)
lazyInjector.provide(for: .networkService, usingFactory: NetworkService.init)

/*:
 Since we are using the `LazyInjector`, no closure we passed has been executed yet.
 They will only be executed when they get resolved.
 */

// this will execute all factories we passed for our providers
do {
    try lazyInjector.resolve(from: .dataManager)
} catch {
    print("Error: \(error)")
}

/*:
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

 */

/*:
 ### StrictInjector
 The previous example would fail when using `StrictInjector`, because we provided `.dataManager` before providing `.networkService`, but `DataManager` requires a `.networkService`.
 */

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

/*:
 The output would be:
 ```
 Return: BaseUrl
 Start: DataManager
 Start: NetworkService
 Finish: NetworkService
 Error: keyNotProvided("NetworkService")
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
 */

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

/*:
 ## ToDos
 - finish documentation
 - improve this Playground and set up README.md
 - write UnitTests
 - setup Travis CI
 - add `Injector.rejecting` and `MutableInjector.reject` and implement `Injector.rejecting` in `InjectorDerivingFromMutableInjector`
 - implement `InjectionError.cyclicDependency` and throw it in `LazyInjector`
 
 ## Author

 Valentin Knabel, develop@vknabel.com

 ## License

 EasyInject is available under the MIT license. See the LICENSE file for more info.
 */
