/// A custom error that may be thrown by `ComposedInjector`.
/// This error will always be embedded within `InjectionError`.
public enum ComposedInjectionError<Key: ProvidableKey>: Error {
    /// Contains the error of `ComposedInjector#left` and `ComposedInjector#right` when resolving.
    /// Will only be thrown if both fail.
    case composed(Error, Error)
}

/// Wraps two given `MutableInjector`s into one.
/// By default all operations will be first delegated to `ComposedInjector.left` and thereafter to `ComposedInjector.right`.
/// May throw `ComposedInjectionError` as `InjectionError.customError`.
/// If a reference typed MutableInjector will be used,
/// a copy will be created on `ComposedInjector.provide(key:usingFactory:)`,
/// but there won't be created a copy on `ComposedInjector.init(left:right:)`.
public struct ComposedInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K

    /// The first `Injector` that shall be wrapped.
    public var left: AnyInjector<K>
    /// The second `Injector` that shall be wrapped.
    public var right: AnyInjector<K>

    /**
     Initializes `AnyMutableInjector` with a given `MutableInjector`.

     - Parameter left: The default `MutableInjector` that shall be wrapped.
     - Parameter right: The fallback `MutableInjector` that shall be wrapped.
     */
    public init<L: Injector, R: Injector>(left: L, right: R) where L.Key == Key, R.Key == Key {
        self.left = AnyInjector(injector: left)
        self.right = AnyInjector(injector: right)
    }

    /// See `MutableInjector.resolve(key:)`.
    public mutating func resolve(key: Key) throws -> Providable {
        do {
            return try resolveLeft(key: key)
        } catch let leftError {
            do {
                return try resolveRight(key: key)
            } catch let rightError {
                throw ComposedInjector<Key>.rethrowResolvingErrors(forKey: key, left: leftError, right: rightError)
            }
        }
    }

    /// Aggregates two resolve errors into one single error. 
    ///
    /// - Parameter forKey: The key that could not be resolved.
    /// - Parameter leftError: The error thrown by `ComposedInjector.left`.
    /// - Parameter rightError: The error thrown by `ComposedInjector.right`.
    /// - Returns: The error that shall be thrown.
    private static func rethrowResolvingErrors(forKey key: Key, left leftError: Error, right rightError: Error) -> Error {
        switch (leftError, rightError) {
        case (InjectionError<Key>.keyNotProvided(_), InjectionError<Key>.keyNotProvided(_)):
            return InjectionError<Key>.keyNotProvided(key)
        case (InjectionError<Key>.keyNotProvided(_), _):
            if let rightError = rightError as? InjectionError<Key> {
                return rightError
            } else {
                return InjectionError<Key>.customError(rightError)
            }
        case (_, InjectionError<Key>.keyNotProvided(_)):
            if let leftError = leftError as? InjectionError<Key> {
                return leftError
            } else {
                return InjectionError<Key>.customError(leftError)
            }
        default:
            let composedError = ComposedInjectionError<Key>.composed(leftError, rightError)
            return InjectionError<Key>.customError(composedError)
        }
    }


    /// See `MutableInjector.provide(key:usingFactory:)`.
    public mutating func provide(key: Key, usingFactory factory: @escaping (inout ComposedInjector) throws -> Providable) {
        provideLeft(key: key, usingFactory: factory)
    }

    /// See `Injector.providedKeys`.
    ///
    /// - Returns: The union of the left and right `Injector.providedKeys`.
    public var providedKeys: [K] {
        let leftSet = Set(left.providedKeys)
        return Array(leftSet.union(right.providedKeys))
    }

    /// See `MutableInjector.revoke(key:)`.
    public mutating func revoke(key: K) {
        revokeBoth(key: key)
    }
}

public extension ComposedInjector {
    /// Returns `MutableInjector.resolve(key:)` invoked on `ComposedInjector.left`.
    ///
    /// - Throws: Just passes all errors.
    public mutating func resolveLeft(key: Key) throws -> Providable {
        return try left.resolve(key: key)
    }
    /// Returns `MutableInjector.resolve(key:)` invoked on `ComposedInjector.right`.
    ///
    /// - Throws: Just passes all errors.
    public mutating func resolveRight(key: Key) throws -> Providable {
        return try right.resolve(key: key)
    }
    /// Calls both, `ComposedInjector.resolveLeft(key:)` and `ComposedInjector.resolveRight(key:)`.
    ///
    /// - Throws: `InjectionError`. `InjectionError.customError(_:)` may contain `ComposedInjectionError`.
    /// - Returns: Both results.
    public mutating func resolveBoth(key: Key) throws -> (Providable, Providable) {
        return try (resolveLeft(key: key), resolveRight(key: key))
    }

    /**
     Resolves `InjectedProvider.value` for a given `Provider`.
     Will be performed on the `.left` `Injector`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    public mutating func resolveLeft<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        return try left.resolving(from: provider)
    }

    /**
     Resolves `InjectedProvider.value` for a given `Provider`.
     Will be performed on the `.right` `Injector`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    public mutating func resolveRight<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        return try right.resolving(from: provider)
    }

    /**
     Resolves `InjectedProvider.value` for a given `Provider`.
     Will be performed on the `.left` and thereafter on the `.right` `Injector`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`, may throw `.customError(ComposedInjectionError)`
     */
    public mutating func resolveBoth<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> (Value, Value) {
        return try (resolveLeft(from: provider), resolveRight(from: provider))
    }

    /// Invokes `MutableInjector.provide(key:usingFactory:)` on `ComposedInjector.left`.
    public mutating func provideLeft(key: Key, usingFactory factory: @escaping (inout ComposedInjector) throws -> Providable) {
        var this = self
        left.provide(key: key, usingFactory: { newMutable in
            this.left = newMutable
            return try factory(&this)
        })
    }
    /// Invokes `MutableInjector.provide(key:usingFactory:)` on `ComposedInjector.right`.
    public mutating func provideRight(key: Key, usingFactory factory: @escaping (inout ComposedInjector) throws -> Providable) {
        var this = self
        right = right.providing(key: key, usingFactory: { newMutable in
            this.right = newMutable
            return try factory(&this)
        })
    }
    /// Invokes `MutableInjector.provide(key:usingFactory:)` on `ComposedInjector.left` and `ComposedInjector.left`.
    public mutating func provideBoth(key: Key, usingFactory factory: @escaping (inout ComposedInjector) throws -> Providable) {
        provideLeft(key: key, usingFactory: factory)
        provideRight(key: key, usingFactory: factory)
    }

    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.left` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    public mutating func provideLeft<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout ComposedInjector) throws -> Value) {
        var this = self
        left = left.providing(for: provider, usingFactory: { newMutable -> Value in
            this.left = newMutable
            return try factory(&this)
        })
    }
    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.right` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    public mutating func provideRight<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout ComposedInjector) throws -> Value) {
        var this = self
        right = right.providing(for: provider, usingFactory: { newMutable -> Value in
            this.right = newMutable
            return try factory(&this)
        })
    }
    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.left` and thereafter on the `.right` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    public mutating func provideBoth<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout ComposedInjector) throws -> Value) {
        provideLeft(for: provider, usingFactory: factory)
        provideRight(for: provider, usingFactory: factory)
    }

    /// Invokes `MutableInjector.revoke(key:)` on `ComposedInjector.left`.
    ///
    /// - Parameter key: The key to be removed.
    public mutating func revokeLeft(key: K) {
        left.revoke(key: key)
    }

    /// Invokes `MutableInjector.revoke(key:)` on `ComposedInjector.right`.
    ///
    /// - Parameter key: The key to be removed.
    public mutating func revokeRight(key: K) {
        right.revoke(key: key)
    }

    /// Invokes `MutableInjector.revoke(key:)` on `ComposedInjector.left` and `ComposedInjector.right`.
    ///
    /// - Parameter key: The key to be removed.
    public mutating func revokeBoth(key: K) {
        left.revoke(key: key)
        right.revoke(key: key)
    }
}

public extension ComposedInjector {
    /**
     Resolves `InjectedProvider.value` for a given `Provider`.
     Will be performed on the `.left` `Injector`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    public func resolvingLeft<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        return try left.resolving(from: provider)
    }

    /**
     Resolves `InjectedProvider.value` for a given `Provider`.
     Will be performed on the `.right` `Injector`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    public func resolvingRight<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        return try right.resolving(from: provider)
    }

    /**
     Resolves `InjectedProvider.value` for a given `Provider`.
     Will be performed on the `.left` and thereafter on the `.right` `Injector`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: A tuple of the left and right `Providable`, that have been added.
     - Throws: `InjectionError`, may throw `.customError(ComposedInjectionError)`
     */
    public func resolvingBoth<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> (Value, Value) {
        return try (left.resolving(from: provider), right.resolving(from: provider))
    }

    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.left` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providingLeft<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout ComposedInjector) throws -> Value)
        -> ComposedInjector {
        var this = self
        this.left = left.providing(for: provider, usingFactory: { newMutable -> Value in
            this.left = newMutable
            return try factory(&this)
        })
        return this
    }
    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.right` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providingRight<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout ComposedInjector) throws -> Value)
        -> ComposedInjector {
        var this = self
        this.right = right.providing(for: provider, usingFactory: { newMutable -> Value in
            this.right = newMutable
            return try factory(&this)
        })
        return this
    }
    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.left` and thereafter on the `.right` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providingBoth<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout ComposedInjector) throws -> Value)
        -> ComposedInjector {
        return providingLeft(for: provider, usingFactory: factory)
            .providingRight(for: provider, usingFactory: factory)
    }

    /// Invokes `Injector.revoking(key:)` on `ComposedInjector.left`.
    ///
    /// - Parameter key: The key to be removed.
    /// - Returns: A `ComposedInjector` that revoked the key on `ComposedInjector.left`.
    public func revokingLeft(key: K) -> ComposedInjector {
        return ComposedInjector(left: left.revoking(key: key), right: right)
    }

    /// Invokes `Injector.revoking(key:)` on `ComposedInjector.right`.
    ///
    /// - Parameter key: The key to be removed.
    /// - Returns: A `ComposedInjector` that revoked the key on `ComposedInjector.right`.
    public func revokingRight(key: K) -> ComposedInjector {
        return ComposedInjector(left: left, right: right.revoking(key: key))
    }

    /// Invokes `Injector.revoking(key:)` on `ComposedInjector.left` and `ComposedInjector.right`.
    ///
    /// - Parameter key: The key to be removed.
    /// - Returns: A `ComposedInjector` that revoked the key on `ComposedInjector.left` and `ComposedInjector.right`.
    public func revokingBoth(key: K) -> ComposedInjector {
        return ComposedInjector(left: left.revoking(key: key), right: right.revoking(key: key))
    }
}

public extension ComposedInjector {
    /**
     Creates an instance providing a value for a given `Provider`.
     This will only be performed on `ComposedInjector.left`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providingLeft<Value: Providable>(
        _ instance: @autoclosure @escaping  () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingLeft(for: provider, usingFactory: { _ in return instance() })
    }

    /**
     Creates an instance providing a value for a given `Provider`.
     This will only be performed on the `ComposedInjector.right`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providingRight<Value: Providable>(
        _ instance: @autoclosure @escaping  () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingRight(for: provider, usingFactory: { _ in return instance() })
    }

    /**
     Creates an instance providing a value for a given `Provider`.
     This will only be performed on `ComposedInjector.left` and thereafter on `ComposedInjector.right`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providingBoth<Value: Providable>(
        _ instance: @autoclosure @escaping  () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingBoth(for: provider, usingFactory: { _ in return instance() })
    }
}

public extension ComposedInjector {
    /**
     Additionally provides a value for a given `Provider`.
     This will only be performed on `ComposedInjector.left`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public mutating func provideLeft<Value: Providable>(
        _ instance: @autoclosure @escaping () -> Value,
        for provider: Provider<Key, Value>) {
        provideLeft(for: provider, usingFactory: { _ in return instance() })
    }

    /**
     Additionally provides a value for a given `Provider`.
     This will only be performed on `ComposedInjector.right`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public mutating func provideRight<Value: Providable>(
        _ instance: @autoclosure @escaping () -> Value,
        for provider: Provider<Key, Value>) {
        provideRight(for: provider, usingFactory: { _ in return instance() })
    }

    /**
     Additionally provides a value for a given `Provider`.
     This will only be performed on `ComposedInjector.left` and thereafter on `ComposedInjector.right`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public mutating func provideBoth<Value: Providable>(
        _ instance: @autoclosure @escaping () -> Value,
        for provider: Provider<Key, Value>) {
        provideBoth(for: provider, usingFactory: { _ in return instance() })
    }
}
