/// Wraps a given `Injector` in order to lose type details, but keeps it mutable.
/// - ToDo: Replace generic `I : Injector` with a `ProvidableKey`
public struct AnyInjector<K : Hashable>: InjectorDerivingFromMutableInjector {
    public typealias Key = K

    /// The internally used `Injector`.
    private var injector: Any
    private let lambdaResolve: (inout AnyInjector, Key) throws -> Providable
    private let lambdaProvide:
        (inout AnyInjector, K, (inout AnyInjector) throws -> Providable) -> Void
    /**
     Initializes `AnyInjector` with a given `MutableInjector`.

     - Parameter injector: The `MutableInjector` that shall be wrapped.
     */
    public init<I: MutableInjector where I.Key == K>(injector: I) {
        self.injector = injector
        #if swift(>=3.0)
        self.lambdaResolve = { (this: inout AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            return try injector.resolve(key: key)
        }
        #else
        self.lambdaResolve = { (inout this: AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            return try injector.resolve(key: key)
        }
        #endif
        self.lambdaProvide = { this, key, factory in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            injector.provide(key: key, usingFactory: { inj in
                var any = AnyInjector(injector: inj)
                return try factory(&any)
            })
        }
    }

    /**
     Initializes `AnyInjector` with a given `Injector`.

     - Parameter injector: The `Injector` that shall be wrapped.
     */
    public init<I: Injector where I.Key == K>(injector: I) {
        self.injector = injector
        #if swift(>=3.0)
        self.lambdaResolve = { (this: inout AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            return try (this.injector as! I).resolving(key: key)
        }
        #else
        self.lambdaResolve = { (inout this: AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            return try (this.injector as! I).resolving(key: key)
        }
        #endif
        self.lambdaProvide = { this, key, factory in
            // swiftlint:disable:next force_cast
            let injector = this.injector as! I
            this.injector = injector.providing(key: key, usingFactory: { inj in
                var any = AnyInjector(injector: inj)
                return try factory(&any)
            })
        }
    }

    public func copy() -> AnyInjector {
        return self
    }

    #if swift(>=3.0)
    public mutating func resolve(key: K) throws -> Providable {
        return try self.lambdaResolve(&self, key)
    }
    public mutating func provide(
        key: K,
        usingFactory factory: (inout AnyInjector) throws -> Providable) {
        self.lambdaProvide(&self, key, factory)
    }
    #else
    public mutating func resolve(key key: K) throws -> Providable {
    return try self.lambdaResolve(&self, key)
    }
    public mutating func provide(
    key key: K,
    usingFactory factory: (inout AnyInjector) throws -> Providable) {
    self.lambdaProvide(&self, key, factory)
    }
    #endif
}
