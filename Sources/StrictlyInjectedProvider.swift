public struct StrictlyInjectedProvider<I: Injector>: InjectedProvider {
    public typealias Key = I.Key
    public typealias Injected = I

    private let key: Key
    private let state: InjectedProviderResolveState<Key>

    #if swift(>=3.0)
    public init(key: Key,
        withInjector injector: inout I,
        usingFactory factory: (inout I) throws -> Providable) {
        self.key = key
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }
    #else
    public init(key: Key,
        inout withInjector injector: I,
        usingFactory factory: (inout I) throws -> Providable) {
        self.key = key
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }
    #endif


    #if swift(>=3.0)
    public func resolve(withInjector injector: inout Injected) throws -> Providable {
        return try state.resolve(withInjector: &injector)
    }
    #else
    public func resolve(inout withInjector injector: Injected) throws -> Providable {
        return try state.resolve(withInjector: &injector)
    }
    #endif
}

public func ==
    <K: ProvidableKey>
    (lhs: StrictlyInjectedProvider<K>, rhs: StrictlyInjectedProvider<K>) -> Bool {
    return lhs.key == rhs.key
}
