
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
        usingFactory factory: (inout Self) throws -> Value) -> Self {
        return providing(key: provider.key, usingFactory: factory)
    }

    /// By default implements `InjectorDerivingFromMutableInjector.copy()` for all value types by just returning self.
    func copy() -> Self {
        return self
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
        (for provider: Provider<Key, Value>, usingFactory factory: (inout Self) throws -> Value) {
        provide(key: provider.key, usingFactory: factory)
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
    public func providing(key key: Self.Key, usingFactory factory: (inout Self) throws -> Providable) -> Self {
        var copy = self.copy()
        copy.provide(key: key, usingFactory: { this in try factory(&this) })
        return copy
    }

    /// Implements `Injector.resolving(key:)`
    /// by using `InjectorDerivingFromMutableInjector.copy()` and `MutableInjector.resolve(key:)`.
    public func resolving(key key: Self.Key) throws -> Providable {
        var copy = self.copy()
        return try copy.resolve(key: key)
    }
}

public extension Injector {
    #if swift(>=3.0)
    /**
     Creates an instance providing a value for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providing<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) -> Self {
        return providing(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    /**
     Creates an instance providing a value for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public func providing<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) -> Self {
        return providing(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}

public extension MutableInjector {
    #if swift(>=3.0)
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public mutating func provide<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        provide(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public mutating func provide<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        provide(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}

public extension MutableInjector where Self: AnyObject {
    #if swift(>=3.0)
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public func provide<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        var this = self
        this.provide(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    public func provide<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        var this = self
        this.provide(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
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

    #if swift(>=3.0)
    /// Evaluates the passed factory.
    ///
    /// - Parameter injector: The injector that shall be used.
    /// - Parameter factory: The factory that shall be evaluated.
    public init<I: Injector where I.Key == K>(
        withInjector injector: inout I,
        from factory: (inout I) throws -> Providable) {
        do {
            self = .success(try factory(&injector))
        } catch let error as InjectionError<K> {
            self = .failure(error)
        } catch {
            self = .failure(.customError(error))
        }
    }
    #else
    /// Evaluates the passed factory.
    ///
    /// - Parameter injector: The injector that shall be used.
    /// - Parameter factory: The factory that shall be evaluated.
    public init<I: Injector where I.Key == K>(
        inout withInjector injector: I,
        from factory: (inout I) throws -> Providable) {
        do {
            self = .success(try factory(&injector))
        } catch let error as InjectionError<K> {
            self = .failure(error)
        } catch {
            self = .failure(.customError(error))
        }
    }
    #endif

    #if swift(>=3.0)
    /// Constructs a factory and returns its `InjectedProviderResolveState`.
    ///
    /// - Parameter injector: The injector that shall be used.
    /// - Parameter factory: The factory that shall be evaluated.
    /// - Returns: `InjectedProviderResolveState.failure` when factory throwed, 
    ///    `InjectedProviderResolveState.success` otherwise.
    public static func from<I: Injector where I.Key == K>(
        factory: (inout I) throws -> Providable,
        for injector: inout I) -> InjectedProviderResolveState {
        return self.init(withInjector: &injector, from: factory)
    }
    #else
    /// Constructs a factory and returns its `InjectedProviderResolveState`.
    ///
    /// - Parameter injector: The injector that shall be used.
    /// - Parameter factory: The factory that shall be evaluated.
    /// - Returns: `InjectedProviderResolveState.failure` when factory throwed,
    ///    `InjectedProviderResolveState.success` otherwise.
    public static func from<I: Injector where I.Key == K>(
        factory: (inout I) throws -> Providable,
        inout for injector: I) -> InjectedProviderResolveState {
        return self.init(withInjector: &injector, from: factory)
    }
    #endif

    #if swift(>=3.0)
    /// Either throws or returns the value.
    /// 
    /// - Parameter injector: Will be ignored.
    /// - Throws: On case `InjectedProviderResolveState.failure`.
    /// - Returns: On case `InjectedProviderResolveState.success`.
    public func resolve<I: Injector where I.Key == K>(withInjector injector: inout I) throws -> Providable {
        switch self {
        case let .failure(error):
            throw error
        case let .success(value):
            return value
        }
    }
    #else
    /// Either throws or returns the value.
    ///
    /// - Parameter injector: Will be ignored.
    /// - Throws: On case `InjectedProviderResolveState.failure`.
    /// - Returns: On case `InjectedProviderResolveState.success`.
    public func resolve<I: Injector where I.Key == K>(inout withInjector injector: I) throws -> Providable {
        switch self {
        case let .failure(error):
            throw error
        case let .success(value):
            return value
        }
    }
    #endif
}
