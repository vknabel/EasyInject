/// An `InjectedProvider` that will evaluate exactly once on `LazilyInjectedProver.resolve(key:)`.
public final class LazilyInjectedProvider<I: Injector>: InjectedProvider {
    public typealias Key = I.Key
    public typealias Injected = I

    private let valueFactory: (inout I) throws -> Providable
    private let key: Key
    private var state: InjectedProviderResolveState<Key>?

    #if swift(>=3.0)
    /// See `InjectedProvider.resolve(withInjector:)`.
    ///
    /// - Throws:  An error wrapped in `InjectedProvider`.
    public func resolve(withInjector injector: inout Injected) throws -> Providable {
        if let state = state {
            return try state.resolve(withInjector: &injector)
        } else {
            state = InjectedProviderResolveState(withInjector: &injector, from: self.valueFactory)
            return try self.resolve(withInjector: &injector)
        }
    }
    #else
    /// See `InjectedProvider.resolve(withInjector:)`.
    ///
    /// - Throws:  An error wrapped in `InjectedProvider`.
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
    /// See `InjectedProvider.init(key:withInjector:usingFactory:)`.
    /// Won't evaluate factory.
    public init(key: Key,
                withInjector injector: inout Injected,
                usingFactory factory: @escaping (inout Injected) throws -> Providable) {
        self.key = key
        self.valueFactory = factory
    }
    #else
    /// See `InjectedProvider.init(key:withInjector:usingFactory:)`.
    /// Won't evaluate factory.
    public init(key: Key,
                inout withInjector injector: Injected,
                usingFactory factory: (inout Injected) throws -> Providable) {
        self.key = key
        self.valueFactory = factory
    }
    #endif

    #if swift(>=3.0)
    /// Implements `Equatable` for all `LazilyInjectedProvider`s.
    /// :nodoc:
    public static func ==<K: ProvidableKey>(lhs: LazilyInjectedProvider<K>, rhs: LazilyInjectedProvider<K>) -> Bool {
        return lhs.key == rhs.key
    }
    #endif
}

#if !swift(>=3.0)
/// Implements `Equatable` for all `LazilyInjectedProvider`s.
/// :nodoc:
public func ==<K: ProvidableKey>(lhs: LazilyInjectedProvider<K>, rhs: LazilyInjectedProvider<K>) -> Bool {
    return lhs.key == rhs.key
}
#endif
