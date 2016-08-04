public struct StrictInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K
    private var strictProviders: [K: Any] = [:]

    public init() { }

    public func copy() -> StrictInjector {
        return self
    }
    public mutating func resolve(key key: Key) throws -> Providable {
        guard let untyped = strictProviders[key]
            else { throw InjectionError<Key>.keyNotProvided(key) }
        guard let typed = untyped as? StrictlyInjectedProvider<StrictInjector>
            else { throw InjectionError<Key>
                .invalidInjection(key: key, injected: untyped, expected: StrictlyInjectedProvider<StrictInjector>.self) }
        return try typed.resolve(withInjector: &self)
    }

    public mutating func provide(key key: K, usingFactory factory: (inout StrictInjector) throws -> Providable) {
        strictProviders[key] = StrictlyInjectedProvider(key: key,
                                                        withInjector: &self,
                                                        usingFactory: factory)
        /// ToDo: evaluate that there is no problem here (think of dependencies)
    }
}
