public struct LazyInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K

    private var lazyProviders: [K: AnyObject] = [:]

    public init() { }

    public func copy() -> LazyInjector {
        return self
    }

    public mutating func resolve(key key: Key) throws -> Providable {
        guard let untyped = lazyProviders[key]
            else { throw InjectionError<Key>.keyNotProvided(key) }
        guard let typed = untyped as? LazilyInjectedProvider<LazyInjector>
            else { throw InjectionError<Key>
                .invalidInjection(key: key, injected: untyped, expected: LazilyInjectedProvider<LazyInjector>.self) }
        return try typed.resolve(withInjector: &self)
    }

    public mutating func provide(key key: K, usingFactory factory: (inout LazyInjector<K>) throws -> Providable) {
        lazyProviders[key] = LazilyInjectedProvider(key: key,
                                                    withInjector: &self,
                                                    usingFactory: factory)
    }
}
