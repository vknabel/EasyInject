public struct StrictlyInjectedProvider<I: Injector, V: Providable>: InjectedProvider {
    public typealias Value = V
    public typealias Key = I.Key
    public typealias Injected = I

    private let provider: Provider<Key, Value>
    private let state: InjectedProviderResolveState<Key, V>

    #if swift(>=3.0)
    public init(
        provider: Provider<Key, V>,
        withInjector injector: inout I,
        usingFactory factory: (inout I) throws -> Value) {
        self.provider = provider
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }
    #else
    public init(
        provider: Provider<Key, V>,
        inout withInjector injector: I,
        usingFactory factory: (inout I) throws -> Value) {
        self.provider = provider
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }
    #endif

    public var key: Key {
        return provider.key
    }

    #if swift(>=3.0)
    public func resolve(withInjector injector: inout Injected) throws -> Value {
        return try state.resolve(withInjector: &injector)
    }
    #else
    public func resolve(inout withInjector injector: Injected) throws -> Value {
        return try state.resolve(withInjector: &injector)
    }
    #endif
}

public func ==
    <K: ProvidableKey, V: Providable>
    (lhs: StrictlyInjectedProvider<K, V>, rhs: StrictlyInjectedProvider<K, V>) -> Bool {
    return lhs.provider == rhs.provider
}
