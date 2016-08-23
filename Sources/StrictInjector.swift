/// A basic implementation of `MutableInjector` that evaluates all factories on provide.
public struct StrictInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
    public typealias Key = K
    private var strictProviders: [K: Any] = [:]

    /// Creates an empty `StrictInjector`.
    public init() { }

    #if swift(>=3.0)
    /// See `MutableInjector.resolve(key:)`.
    public mutating func resolve(key: Key) throws -> Providable {
        guard let untyped = strictProviders[key]
            else { throw InjectionError<Key>.keyNotProvided(key) }
        let typed = untyped as! StrictlyInjectedProvider<StrictInjector>
        return try typed.resolve(withInjector: &self)
    }
    #else
    /// See `MutableInjector.resolve(key:)`.
    public mutating func resolve(key key: Key) throws -> Providable {
        guard let untyped = strictProviders[key]
            else { throw InjectionError<Key>.keyNotProvided(key) }
        let typed = untyped as! StrictlyInjectedProvider<StrictInjector>
        return try typed.resolve(withInjector: &self)
    }
    #endif

    #if swift(>=3.0)
    /// See `MutableInjector.provide(key:usingFactory:)`.
    public mutating func provide(key: K, usingFactory factory: @escaping (inout StrictInjector) throws -> Providable) {
        strictProviders[key] = StrictlyInjectedProvider(key: key,
                                                        withInjector: &self,
                                                        usingFactory: factory)
        /// ToDo: evaluate that there is no problem here (think of dependencies)
    }
    #else
    /// See `MutableInjector.provide(key:usingFactory:)`.
    public mutating func provide(key key: K, usingFactory factory: (inout StrictInjector) throws -> Providable) {
        strictProviders[key] = StrictlyInjectedProvider(key: key,
                                                        withInjector: &self,
                                                        usingFactory: factory)
        /// ToDo: evaluate that there is no problem here (think of dependencies)
    }
    #endif

    #if swift(>=3.0)
    /// See `MutableInjector.revoke(key:)`.
    public mutating func revoke(key: K) {
        strictProviders.removeValue(forKey: key)
    }
    #else
    /// See `MutableInjector.revoke(key:)`.
    public mutating func revoke(key key: K) {
        strictProviders.removeValueForKey(key)
    }
    #endif

    /// See `Injector.providedKeys`.
    public var providedKeys: [K] {
        return Array(strictProviders.keys)
    }
}
