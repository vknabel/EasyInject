/// A custom error that may be thrown by `ComposedInjector`.
/// This error will always be embedded within `InjectionError`.
public enum ComposedInjectionError<Key: ProvidableKey>: ErrorProtocol {
    #if swift(>=3.0)
    #else
    public typealias ErrorProtocol = ErrorType
    #endif

    /// Contains the error of `ComposedInjector#left` and `ComposedInjector#right` when resolving.
    /// Will only be thrown if both fail.
    case composed(ErrorProtocol, ErrorProtocol)
}

/// Wraps two given `MutableInjector`s into one.
/// By default all operations will be first delegated to `.left` and thereafter to `.right`.
/// May throw `ComposedInjectionError` as `InjectionError.customError`.
/// If a reference typed MutableInjector will be used,
/// a copy will be created on `.provide(for:,usingFactory)`,
/// but there won't be created a copy on `init`.
public struct ComposedInjector
    <L: Injector, R: Injector where L.Key == R.Key>
    : InjectorDerivingFromMutableInjector {
    public typealias Key = L.Key

    /// The first `Injector` that shall be wrapped.
    public var left: L
    /// The second `Injector` that shall be wrapped.
    public var right: R
    /**
     Initializes `AnyMutableInjector` with a given `MutableInjector`.

     - Parameter left: The default `MutableInjector` that shall be wrapped.
     - Parameter right: The fallback `MutableInjector` that shall be wrapped.
     */
    public init(left: L, right: R) {
        self.left = left
        self.right = right
    }

    public func copy() -> ComposedInjector {
        return self
    }

    public mutating func resolve<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        do {
            return try resolveLeft(from: provider)
        } catch let leftError {
            do {
                return try resolveRight(from: provider)
            } catch let rightError {
                let composedError = ComposedInjectionError<Key>.composed(leftError, rightError)
                throw InjectionError<Key>.customError(composedError)
            }
        }
    }
    public mutating func provide<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout ComposedInjector) throws -> Value) {
        provideLeft(for: provider, usingFactory: factory)
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

    /**
     Additionally provides a value given as a factory for a given `Provider`.
     This will only be performed on the `.left` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    public mutating func provideLeft<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout ComposedInjector) throws -> Value) {
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
        usingFactory factory: (inout ComposedInjector) throws -> Value) {
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
        usingFactory factory: (inout ComposedInjector) throws -> Value) {
        provideLeft(for: provider, usingFactory: factory)
        provideRight(for: provider, usingFactory: factory)
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
        usingFactory factory: (inout ComposedInjector) throws -> Value)
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
        usingFactory factory: (inout ComposedInjector) throws -> Value)
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
        usingFactory factory: (inout ComposedInjector) throws -> Value)
        -> ComposedInjector {
        return providingLeft(for: provider, usingFactory: factory)
            .providingRight(for: provider, usingFactory: factory)
    }
}

public extension ComposedInjector {
    /**
     Creates an instance providing a value for a given `Provider`.
     This will only be performed on the `.left` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    #if swift(>=3.0)
    public func providingLeft<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingLeft(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public func providingLeft<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingLeft(for: provider, usingFactory: { _ in return instance() })
    }
    #endif

    /**
     Creates an instance providing a value for a given `Provider`.
     This will only be performed on the `.right` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    #if swift(>=3.0)
    public func providingRight<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingRight(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public func providingRight<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingRight(for: provider, usingFactory: { _ in return instance() })
    }
    #endif

    /**
     Creates an instance providing a value for a given `Provider`.
     This will only be performed on the `.left` and thereafter on the `.right` `Injector`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    #if swift(>=3.0)
    public func providingBoth<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingBoth(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public func providingBoth<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) -> ComposedInjector {
        return providingBoth(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}

public extension ComposedInjector {
    /**
     Additionally provides a value for a given `Provider`.
     This will only be performed on the `.left` `Injector`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    #if swift(>=3.0)
    public mutating func provideLeft<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        provideLeft(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public mutating func provideLeft<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        provideLeft(for: provider, usingFactory: { _ in return instance() })
    }
    #endif

    /**
     Additionally provides a value for a given `Provider`.
     This will only be performed on the `.right` `Injector`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    #if swift(>=3.0)
    public mutating func provideRight<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        provideRight(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public mutating func provideRight<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        provideRight(for: provider, usingFactory: { _ in return instance() })
    }
    #endif

    /**
     Additionally provides a value for a given `Provider`.
     This will only be performed on the `.left` and thereafter on the `.right` `Injector`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    #if swift(>=3.0)
    public mutating func provideBoth<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        provideBoth(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public mutating func provideBoth<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        provideBoth(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}
