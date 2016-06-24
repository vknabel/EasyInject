/// Derives `Injector#providing` for structs by using `Injector.provide`.
public protocol InjectorDerivingFromMutableInjector: MutableInjector { }

public extension InjectorDerivingFromMutableInjector {
    public func providing<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout Self) throws -> Value) -> Self {
        var copy = self
        copy.provide(for: provider, usingFactory: { this in try factory(&this) })
        return copy
    }
    public func resolving<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value {
        var copy = self
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
    public func providing<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) -> Self {
        return providing(for: provider, usingFactory: { _ in return instance() })
    }
}

public extension MutableInjector {
    /**
     Additionally provides a value for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter instance: The provided `Providable`. Depending on `Self`, evaluated lazily.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    public mutating func provide<Value: Providable>(
        _ instance: @autoclosure(escaping) () -> Value,
        for provider: Provider<Key, Value>) {
        provide(for: provider, usingFactory: { _ in return instance() })
    }
}

public enum InjectedProviderResolveState<K: ProvidableKey, V: Providable> {
    case failure(InjectionError<K>)
    case success(V)

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

    public static func from<I: Injector where I.Key == K>(
        factory: (inout I) throws -> V,
        for injector: inout I) -> InjectedProviderResolveState<K, V> {
        return self.init(withInjector: &injector, from: factory)
    }

    public func resolve<I: Injector where I.Key == K>(withInjector injector: inout I) throws -> V {
        switch self {
        case let .failure(error):
            throw error
        case let .success(value):
            return value
        }
    }
}
