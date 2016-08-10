/// Wraps a given `MutableInjector` in order to add reference semantics.
public final class GlobalInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector, MutableInjector {
    public typealias Key = K

    /// The internally used `Injector`.
    private var injector: AnyInjector<K>
    /**
     Initializes `AnyInjector` with a given `Injector`.

     - Parameter injector: The `Injector` that shall be wrapped.
     */
    public init<I: Injector where I.Key == Key>(injector: I) {
        self.injector = AnyInjector(injector: injector)
    }

    /// Creates a deep copy of `GlobalInjector` with the same contents.
    /// Overrides default `InjectorDerivingFromMutableInjector.copy()`.
    ///
    /// - Returns: A new `GlobalInjector`.
    public func copy() -> GlobalInjector {
        return GlobalInjector(injector: injector.copy())
    }

    /// Implements `MutableInjector.resolve(key:)`
    public func resolve(key key: Key) throws -> Providable {
        return try injector.resolve(key: key)
    }

    /// Implements `MutableInjector.provide(key:usingFactory:)`
    public func provide(key key: Key, usingFactory factory: (inout GlobalInjector) throws -> Providable) {
        #if swift(>=3.0)
            return self.injector.provide(key: key) { (injector: inout AnyInjector<K>) in
                var this = self
                defer { self.injector = this.injector }
                return try factory(&this)
            }
        #else
            return self.injector.provide(key: key) { (inout injector: AnyInjector<K>) in
                var this = self
                defer { self.injector = this.injector }
                return try factory(&this)
            }
        #endif
    }

    #if swift(>=3.0)
    /// See `MutableInjector.revoke(key:)`.
    public func revoke(key: K) {
        injector.revoke(key: key)
    }
    #else
    /// See `MutableInjector.revoke(key:)`.
    public func revoke(key key: K) {
        injector.revoke(key: key)
    }
    #endif

    /// Implements `Injector.providedKeys` by passing the internal provided keys.
    public var providedKeys: [K] {
        return injector.providedKeys
    }
}
