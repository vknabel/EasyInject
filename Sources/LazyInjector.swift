/// A basic implementation of `MutableInjector` that evaluates all factories on resolve.
public struct LazyInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K

    private var lazyProviders: [K: AnyObject] = [:]

    /// Creates an empty `StrictInjector`.
    public init() { }

    /// See `MutableInjector.resolve(key:)`.
    public mutating func resolve(key key: Key) throws -> Providable {
        guard let untyped = lazyProviders[key]
            else { throw InjectionError<Key>.keyNotProvided(key) }
        guard let typed = untyped as? LazilyInjectedProvider<LazyInjector>
            else { throw InjectionError<Key>
                .invalidInjection(key: key, injected: untyped, expected: LazilyInjectedProvider<LazyInjector>.self) }
        return try typed.resolve(withInjector: &self)
    }

    /// See `MutableInjector.provide(key:usingFactory:)`.
    public mutating func provide(key key: K, usingFactory factory: (inout LazyInjector<K>) throws -> Providable) {
        lazyProviders[key] = LazilyInjectedProvider(key: key,
                                                    withInjector: &self,
                                                    usingFactory: factory)
    }

    /// See `Injector.providedKeys`.
    public var providedKeys: [K] {
        return Array(lazyProviders.keys)
    }
}
