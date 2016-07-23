public struct StrictInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K
    private var strictProviders: [K: Any] = [:]

    public init() { }

    public func copy() -> StrictInjector<K> {
        return self
    }
    public mutating func resolve<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        guard let untyped = strictProviders[provider.key]
            else { throw InjectionError<Key>.keyNotProvided(provider.key) }
        guard let typed = untyped as? StrictlyInjectedProvider<StrictInjector<K>, Value>
            else { throw InjectionError<Key>
                .nonMatchingType(provided: untyped, expected: Value.self) }
        return try typed.resolve(withInjector: &self)
    }

    public mutating func provide<Value: Providable>(for provider: Provider<Key, Value>,
                                 usingFactory factory: (inout StrictInjector<K>) throws -> Value) {
        strictProviders[provider.key] = StrictlyInjectedProvider(provider: provider,
                                                                 withInjector: &self,
                                                                 usingFactory: factory)
        /// ToDo: evaluate that there is no problem here (think of dependencies)
    }
}
