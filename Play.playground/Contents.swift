/*:
 # EasyInject
 EasyInject is designed to be an easy to use, lightweight composition and dependency injection library.
 Instead of injecting instances for specific types, you provide instances for keys, without losing any type information. This enables its `Injector`s to be used as a composable, dynamic and typesafe data structure. It may be comparable with a Dictionary that may contain several types, without losing type safety.

 ## Introduction
 In order to inject your dependencies, you first need to prepare your key by implementing `Hashable`.
 */

import EasyInject

// As all `String`s are `Hashable`, there's nothing to do here

/*:
 Now we need to define our keys, by setting up `Provider`s with `String`s and our type hints.
 */
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

final class NetworkService {
    let baseUrl: String
    init<I: Injector>(injector: inout I) throws where I.Key == String {
        print("Start: NetworkService")
        baseUrl = try injector.resolving(from: .baseUrl)
        print("Finish: NetworkService")
    }
}
final class DataManager {
    let networkService: NetworkService
    init<I: Injector>(injector: inout I) throws where I.Key == String {
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
 Cyclic dependencies will be caught and thrown as an error.

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
 ### GlobalInjector
 A `GobalInjector` wraps another `Injector` in order to make it act like a class.
 */
var globalInjector = GlobalInjector<String>(injector: strictInjector)
let second = globalInjector
// `globalInjector` may be mutated as it is a class.
second.provide("https://vknabel.github.io/EasyInject", for: .baseUrl)
try? globalInjector.resolve(from: .baseUrl) as String
if let left = try? globalInjector.resolve(from: .baseUrl),
    let right = try? globalInjector.resolve(from: .baseUrl),
    left == right {
    // both `right` and `left` contain `"https://vknabel.github.io/EasyInject"` for `.baseUrl` due to reference semantics
}

/*:
 ### ComposedInjector
 A `ComposedInjector` consists of two other `Injector`s.
 The call `.resolve(from:)` will target the `.left` `Injector` and on failure, the `.right` one.
 `.provide(for:,usingFactory:)` defaults to `.provideLeft(for:,usingFactory:)` which will provide the factory only to the `.left` one.
 
 Usually the left `Injector` will be the local one, whereas the right one is a global one. This makes it possible to cascade `ComposedInjector`s from your root controller down to your leaf controllers.
 */
var composedInjector = ComposedInjector(left: StrictInjector(), right: globalInjector)
composedInjector.provideLeft("https://vknabel.github.io/EasyInject/Structs/ComposedInjector.html", for: .baseUrl)
do {
    try composedInjector.resolveBoth(from: .baseUrl)
    // returns `("https://vknabel.github.io/EasyInject/Structs/ComposedInjector.html", "https://vknabel.github.io/EasyInject")`
} catch {
    print("Error: \(error)")
}

/*:
 ## Author

 Valentin Knabel, develop@vknabel.com

 ## License

 EasyInject is available under the MIT license. See the LICENSE file for more info.
 */
