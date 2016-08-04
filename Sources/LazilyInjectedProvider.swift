public final class LazilyInjectedProvider<I: Injector>: InjectedProvider {
    public typealias Key = I.Key
    public typealias Injected = I

    private let valueFactory: (inout I) throws -> Providable
    private let key: Key
    private var state: InjectedProviderResolveState<Key>?

    #if swift(>=3.0)
    public func resolve(withInjector injector: inout Injected) throws -> Providable {
        if let state = state {
            return try state.resolve(withInjector: &injector)
        } else {
            state = InjectedProviderResolveState(withInjector: &injector, from: self.valueFactory)
            return try self.resolve(withInjector: &injector)
        }
    }
    #else
    public func resolve(inout withInjector injector: Injected) throws -> Providable {
        if let state = state {
            return try state.resolve(withInjector: &injector)
        } else {
            state = InjectedProviderResolveState(withInjector: &injector, from: self.valueFactory)
            return try self.resolve(withInjector: &injector)
        }
    }
    #endif

    #if swift(>=3.0)
    public init(key: Key,
                withInjector injector: inout Injected,
                usingFactory factory: (inout Injected) throws -> Providable) {
        self.key = key
        self.valueFactory = factory
    }
    #else
    public init(key: Key,
                inout withInjector injector: Injected,
                usingFactory factory: (inout Injected) throws -> Providable) {
        self.key = key
        self.valueFactory = factory
    }
    #endif
}

public func ==<K: ProvidableKey>(lhs: LazilyInjectedProvider<K>,
               rhs: LazilyInjectedProvider<K>) -> Bool {
    return lhs.key == rhs.key
}
