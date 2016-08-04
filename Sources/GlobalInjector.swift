/// Wraps a given `MutableInjector` in order to add reference semantics.
public final class GlobalInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector, MutableInjector {
    public typealias Key = K

    /// The internally used `Injector`.
    private var injector: AnyInjector<K>
    /**
     Initializes `AnyMutableInjector` with a given `MutableInjector`.

     - Parameter injector: The `MutableInjector` that shall be wrapped.
     */
    public init<I: Injector where I.Key == Key>(injector: I) {
        self.injector = AnyInjector(injector: injector)
    }

    public func copy() -> GlobalInjector {
        return GlobalInjector(injector: injector)
    }

    public func resolve(key key: Key) throws -> Providable {
        return try injector.resolve(key: key)
    }

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
}
