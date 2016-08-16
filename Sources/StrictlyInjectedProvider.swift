/// The `InjectedProvider` for `StrictInjector`.
/// All factories will be evaluated immediately.
/// If the factory throws an error, it will be stored and throwed on `StrictlyInjectedProvider.resolve(withInjector:)`.
public struct StrictlyInjectedProvider<I: Injector>: InjectedProvider {
    public typealias Key = I.Key
    public typealias Injected = I

    private let key: Key
    private let state: InjectedProviderResolveState<Key>

    #if swift(>=3.0)
    /// Creates a strictly injected provider. The factory will be evaluated synchronously.
    /// For more details see `InjectedProvider.init(key:withInjector:usingFactory:)`.
    public init(key: Key,
        withInjector injector: inout I,
        usingFactory factory: @escaping (inout I) throws -> Providable) {
        self.key = key
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }
    #else
    /// Creates a strictly injected provider. The factory will be evaluated synchronously.
    /// For more details see `InjectedProvider.init(key:withInjector:usingFactory:)`.
    public init(key: Key,
        inout withInjector injector: I,
        usingFactory factory: (inout I) throws -> Providable) {
        self.key = key
        self.state = InjectedProviderResolveState(withInjector: &injector, from: factory)
    }
    #endif


    #if swift(>=3.0)
    /// Implements `InjectedProvider.resolve(withInjector:)`.
    public func resolve(withInjector injector: inout Injected) throws -> Providable {
        return try state.resolve(withInjector: &injector)
    }
    #else
    /// Implements `InjectedProvider.resolve(withInjector:)`.
    public func resolve(inout withInjector injector: Injected) throws -> Providable {
        return try state.resolve(withInjector: &injector)
    }
    #endif

    #if swift(>=3.0)
    /// `StrictlyInjectedProvider`'s implementation of `Equatable`.
    /// :nodoc:
    public static func ==
        <K: ProvidableKey>
        (lhs: StrictlyInjectedProvider<K>, rhs: StrictlyInjectedProvider<K>) -> Bool {
        return lhs.key == rhs.key
    }
    #endif
}

#if !swift(>=3.0)
/// `StrictlyInjectedProvider`'s implementation of `Equatable`.
/// :nodoc:
public func ==
    <K: ProvidableKey>
    (lhs: StrictlyInjectedProvider<K>, rhs: StrictlyInjectedProvider<K>) -> Bool {
    return lhs.key == rhs.key
}
#endif
