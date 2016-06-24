public struct LazyInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K

    private var lazyProviders: [K: AnyObject] = [:]

    public init() { }

    public mutating func resolve<Value: Providable>(
        from provider: Provider<Key, Value>) throws -> Value {
        guard let untyped = lazyProviders[provider.key]
            else { throw InjectionError<Key>.keyNotProvided(provider.key) }
        guard let typed = untyped as? LazilyInjectedProvider<LazyInjector<K>, Value>
            else { throw InjectionError<Key>
                .nonMatchingType(provided: untyped, expected: Value.self) }
        return try typed.resolve(withInjector: &self)
    }
    public mutating func provide<Value: Providable>(for provider: Provider<Key, Value>,
                                 usingFactory factory: (inout LazyInjector<Key>) throws -> Value) {
        lazyProviders[provider.key] = LazilyInjectedProvider(provider: provider,
                                                             withInjector: &self,
                                                             usingFactory: factory)
    }
}
