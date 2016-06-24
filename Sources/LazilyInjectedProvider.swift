public final class LazilyInjectedProvider<I: Injector, V: Providable>: InjectedProvider {
    public typealias Value = V
    public typealias Key = I.Key
    public typealias Injected = I

    private let valueFactory: (inout I) throws -> Value
    private let provider: Provider<Key, Value>
    private var state: InjectedProviderResolveState<Key, V>?

    public func resolve(withInjector injector: inout Injected) throws -> Value {
        if let state = state {
            return try state.resolve(withInjector: &injector)
        } else {
            state = InjectedProviderResolveState(withInjector: &injector, from: self.valueFactory)
            return try self.resolve(withInjector: &injector)
        }
    }

    public init(provider: Provider<Key, Value>,
                withInjector injector: inout Injected,
                usingFactory factory: (inout Injected) throws -> Value) {
        self.provider = provider
        self.valueFactory = factory
    }

    public var key: Key {
        return provider.key
    }
}

public func ==<K: ProvidableKey, V: Providable>(lhs: LazilyInjectedProvider<K, V>,
               rhs: LazilyInjectedProvider<K, V>) -> Bool {
    return lhs.provider == rhs.provider
}
