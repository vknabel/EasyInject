public final class LazilyInjectedProvider<I: Injector, V: Providable>: InjectedProvider {
    public typealias Value = V
    public typealias Key = I.Key
    public typealias Injected = I

    private let valueFactory: (inout I) throws -> Value
    private let provider: Provider<Key, Value>
    private var state: InjectedProviderResolveState<Key, V>?

    #if swift(>=3.0)
    public func resolve(withInjector injector: inout Injected) throws -> Value {
        if let state = state {
            return try state.resolve(withInjector: &injector)
        } else {
            state = InjectedProviderResolveState(withInjector: &injector, from: self.valueFactory)
            return try self.resolve(withInjector: &injector)
        }
    }
    #else
    public func resolve(inout withInjector injector: Injected) throws -> Value {
        if let state = state {
            return try state.resolve(withInjector: &injector)
        } else {
            state = InjectedProviderResolveState(withInjector: &injector, from: self.valueFactory)
            return try self.resolve(withInjector: &injector)
        }
    }
    #endif

    #if swift(>=3.0)
    public init(provider: Provider<Key, Value>,
                withInjector injector: inout Injected,
                usingFactory factory: (inout Injected) throws -> Value) {
        self.provider = provider
        self.valueFactory = factory
    }
    #else
    public init(provider: Provider<Key, Value>,
                inout withInjector injector: Injected,
                usingFactory factory: (inout Injected) throws -> Value) {
        self.provider = provider
        self.valueFactory = factory
    }
    #endif

    public var key: Key {
        return provider.key
    }
}

public func ==<K: ProvidableKey, V: Providable>(lhs: LazilyInjectedProvider<K, V>,
               rhs: LazilyInjectedProvider<K, V>) -> Bool {
    return lhs.provider == rhs.provider
}
