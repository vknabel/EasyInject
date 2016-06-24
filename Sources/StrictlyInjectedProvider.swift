public struct StrictlyInjectedProvider<I: Injector, V: Providable>: InjectedProvider {
    public typealias Value = V
    public typealias Key = I.Key
    public typealias Injected = I

    private let provider: Provider<Key, Value>
    private let state: InjectedProviderResolveState<Key, V>

    public init(
        provider: Provider<Key, V>,
        withInjector injector: inout I,
        usingFactory factory: (inout I) throws -> Value) {
        self.provider = provider
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }

    public var key: Key {
        return provider.key
    }

    public func resolve(withInjector injector: inout Injected) throws -> Value {
        return try state.resolve(withInjector: &injector)
    }
}

public func ==
    <K: ProvidableKey, V: Providable>
    (lhs: StrictlyInjectedProvider<K, V>, rhs: StrictlyInjectedProvider<K, V>) -> Bool {
    return lhs.provider == rhs.provider
}
