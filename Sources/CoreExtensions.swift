
public extension Injector {
    /**
     Resolves `InjectedProvider.value` for a given `Provider`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    func resolving<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value {
        let result = try resolving(key: provider.key)
        if let result = result as? Value {
            return result
        } else {
            throw InjectionError<Key>.nonMatchingType(provided: result, expected: Value.self)
        }
    }

    /**
     Creates an instance providing a value as a factory for a given `Provider`.

     - ToDo: Improve markup for `factory`'s parameter

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    func providing<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: @escaping (inout Self) throws -> Value) -> Self {
        return providing(key: provider.key, usingFactory: factory)
    }

    /// Revokes the value of a given provider.
    ///
    /// - Parameter provider: The provider that's value shall be revoked.
    /// - Returns: A new instance without any value for the provider.
    func revoking<Value: Providable>(for provider: Provider<Key, Value>) -> Self {
        return self.revoking(key: provider.key)
    }

    /// By default implements `InjectorDerivingFromMutableInjector.copy()` for all value types by just returning self.
    func copy() -> Self {
        return self
    }

    /// Determines wether a specific key has been provided.
    ///
    /// - Parameter key: The key that shall be tested for.
    /// - Returns: true if provided. Will also return true if the key cannot be resolved properly.
    func contains(_ key: Key) -> Bool {
        return providedKeys.contains(key)
    }
}

public extension MutableInjector {
    /**
     Additionally provides a value given as a factory for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    mutating func provide
        <Value: Providable>
        (for provider: Provider<Key, Value>, usingFactory factory: @escaping (inout Self) throws -> Value) {
        provide(key: provider.key, usingFactory: factory)
    }

    /// Revokes the value of a given provider.
    ///
    /// - Parameter provider: The provider that's value shall be revoked.
    mutating func revoke<Value: Providable>(for provider: Provider<Key, Value>) {
        revoke(key: provider.key)
    }

    /**
     Resolves `InjectedProvider.value` for a given `Provider`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    mutating func resolve<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value {
        let result = try resolve(key: provider.key)
        if let result = result as? Value {
            return result
        } else {
            throw InjectionError<Key>.nonMatchingType(provided: result, expected: Value.self)
        }
    }
}

public extension Provider {
    /// Automatically generates `Provider#key` from the caller's function and the detected type.
    /// - Parameter function: The function where `.derive()` will be called from.
    /// - Returns: A new `Provider` with a `String` as `ProvidableKey`,
    /// containing type information and the caller's `function`.
    public static func derive<V: Providable>(function: String = #function) -> Provider<String, V> {
        return Provider<String, V>(for: "\(function)(...) -> \(V.self)")
    }
}

/// Derives `Injector#providing` for structs by using `Injector.provide`.
public protocol InjectorDerivingFromMutableInjector: MutableInjector {
    /// Creates a copy of the current instance.
    func copy() -> Self
}

public extension InjectorDerivingFromMutableInjector {
    /// Implements `Injector.providing(key:usingFactory:)` 
    /// by using `InjectorDerivingFromMutableInjector.copy()` and `MutableInjector.provide(key:usingFactory:)`.
    public func providing(key: Self.Key, usingFactory factory: @escaping (inout Self) throws -> Providable) -> Self {
        var copy = self.copy()
        copy.provide(key: key, usingFactory: { this in try factory(&this) })
        return copy
    }

    /// Implements `Injector.resolving(key:)`
    /// by using `InjectorDerivingFromMutableInjector.copy()` and `MutableInjector.resolve(key:)`.
    public func resolving(key: Self.Key) throws -> Providable {
        var copy = self.copy()
        return try copy.resolve(key: key)
    }

    /// Implements `Injector.revoking(key:)`
    /// by using `InjectorDerivingFromMutableInjector.copy()` and `MutableInjector.revoke(key:)`.
    public func revoking(key: Self.Key) -> Self {
        var copy = self.copy()
        copy.revoke(key: key)
        return copy
    }
}

public extension Injector {
    /**
     Creates an instance providing a value for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providing<Value: Providable>(
        _ instance: @autoclosure @escaping () -> Value,
        for provider: Provider<Key, Value>) -> Self {
        return providing(for: provider, usingFactory: { _ in return instance() })
    }
}

public extension MutableInjector {
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public mutating func provide<Value: Providable>(
        _ instance: @autoclosure @escaping () -> Value,
        for provider: Provider<Key, Value>) {
        provide(for: provider, usingFactory: { _ in return instance() })
    }
}

public extension MutableInjector where Self: AnyObject {
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public func provide<Value: Providable>(
        _ instance: @autoclosure @escaping () -> Value,
        for provider: Provider<Key, Value>) {
        var this = self
        this.provide(for: provider, usingFactory: { _ in return instance() })
    }
}

/// Stores the result when evaluating a factory provided 
/// by `Injector.providing(key:usingFactory:)` and similar methods
/// in order to 'replay' it.
public enum InjectedProviderResolveState<K: ProvidableKey> {
    /// When an error occured. 
    /// If the error was of type `InjectionError` it will be passed
    /// otherwise it will be wrapped in `InjectionError.customError`.
    case failure(InjectionError<K>)
    /// Contains the constructed value.
    case success(Providable)

    /// Evaluates the passed factory.
    ///
    /// - Parameter injector: The injector that shall be used.
    /// - Parameter factory: The factory that shall be evaluated.
    public init<I: Injector>(
        withInjector injector: inout I,
        from factory: (inout I) throws -> Providable)
        where I.Key == K {
        do {
            self = .success(try factory(&injector))
        } catch let error as InjectionError<K> {
            self = .failure(error)
        } catch {
            self = .failure(.customError(error))
        }
    }

    /// Constructs a factory and returns its `InjectedProviderResolveState`.
    ///
    /// - Parameter injector: The injector that shall be used.
    /// - Parameter factory: The factory that shall be evaluated.
    /// - Returns: `InjectedProviderResolveState.failure` when factory throwed, 
    ///    `InjectedProviderResolveState.success` otherwise.
    public static func from<I: Injector>(
        factory: (inout I) throws -> Providable,
        for injector: inout I) -> InjectedProviderResolveState where I.Key == K {
        return self.init(withInjector: &injector, from: factory)
    }

    /// Either throws or returns the value.
    /// 
    /// - Parameter injector: Will be ignored.
    /// - Throws: On case `InjectedProviderResolveState.failure`.
    /// - Returns: On case `InjectedProviderResolveState.success`.
    public func resolve<I: Injector>(withInjector injector: inout I) throws -> Providable where I.Key == K {
        switch self {
        case let .failure(error):
            throw error
        case let .success(value):
            return value
        }
    }
}
