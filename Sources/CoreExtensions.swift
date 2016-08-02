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
    public func providing<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout Self) throws -> Value) -> Self {
        var copy = self.copy()
        copy.provide(for: provider, usingFactory: { this in try factory(&this) })
        return copy
    }
    public func resolving<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value {
        var copy = self.copy()
        return try copy.resolve(from: provider)
    }
}

public extension Injector {
    /**
     Creates an instance providing a value for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    #if swift(>=3.0)
    public func providing<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) -> Self {
        return providing(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public func providing<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) -> Self {
        return providing(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}

public extension MutableInjector {
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    #if swift(>=3.0)
    public mutating func provide<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        provide(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public mutating func provide<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        provide(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}

public extension MutableInjector where Self: AnyObject {
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Parameter provider: The `Provider`, an `InjectedProvider` will be constructed of.
     */
    #if swift(>=3.0)
    public func provide<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        var this = self
        this.provide(for: provider, usingFactory: { _ in return instance() })
    }
    #else
    public func provide<Value: Providable>(
        @autoclosure(escaping) instance: () -> Value,
        for provider: Provider<Key, Value>) {
        var this = self
        this.provide(for: provider, usingFactory: { _ in return instance() })
    }
    #endif
}

public enum InjectedProviderResolveState<K: ProvidableKey, V: Providable> {
    case failure(InjectionError<K>)
    case success(V)

    #if swift(>=3.0)
    public init<I: Injector where I.Key == K>(
        withInjector injector: inout I,
        from factory: (inout I) throws -> V) {
        do {
            self = .success(try factory(&injector))
        } catch let error as InjectionError<K> {
            self = .failure(error)
        } catch {
            self = .failure(.customError(error))
        }
    }
    #else
    public init<I: Injector where I.Key == K>(
        inout withInjector injector: I,
                     from factory: (inout I) throws -> V) {
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
    public static func from<I: Injector where I.Key == K>(
        factory: (inout I) throws -> V,
        for injector: inout I) -> InjectedProviderResolveState<K, V> {
        return self.init(withInjector: &injector, from: factory)
    }
    #else
    public static func from<I: Injector where I.Key == K>(
        factory: (inout I) throws -> V,
        inout for injector: I) -> InjectedProviderResolveState<K, V> {
        return self.init(withInjector: &injector, from: factory)
    }
    #endif

    #if swift(>=3.0)
    public func resolve<I: Injector where I.Key == K>(withInjector injector: inout I) throws -> V {
        switch self {
        case let .failure(error):
            throw error
        case let .success(value):
            return value
        }
    }
    #else
    public func resolve<I: Injector where I.Key == K>(inout withInjector injector: I) throws -> V {
        switch self {
        case let .failure(error):
            throw error
        case let .success(value):
            return value
        }
    }
    #endif
}
