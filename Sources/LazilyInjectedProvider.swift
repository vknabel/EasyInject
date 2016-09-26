/// An `InjectedProvider` that will evaluate exactly once on `LazilyInjectedProver.resolve(key:)`.
public final class LazilyInjectedProvider<I: Injector>: InjectedProvider {
    public typealias Key = I.Key
    public typealias Injected = I

    private let valueFactory: (inout I) throws -> Providable
    private let key: Key
    private var state: InjectedProviderResolveState<Key>?

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

    /// See `InjectedProvider.init(key:withInjector:usingFactory:)`.
    /// Won't evaluate factory.
    public init(key: Key,
                withInjector injector: inout Injected,
                usingFactory factory: @escaping (inout Injected) throws -> Providable) {
        self.key = key
        self.valueFactory = factory
    }

    /// Implements `Equatable` for all `LazilyInjectedProvider`s.
    /// :nodoc:
    public static func ==<K: ProvidableKey>(lhs: LazilyInjectedProvider<K>, rhs: LazilyInjectedProvider<K>) -> Bool {
        return lhs.key == rhs.key
    }
}
