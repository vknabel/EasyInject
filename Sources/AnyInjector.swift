/// Wraps a given `Injector` in order to lose type details, but keeps it mutable.
/// - Todo: Replace generic `I : Injector` with a `ProvidableKey`
public struct AnyInjector<K : Hashable>: InjectorDerivingFromMutableInjector {
    public typealias Key = K

    /// The internally used `Injector`.
    private var injector: Any
    private let lambdaRevoke: (inout AnyInjector, Key) -> Void
    private let lambdaKeys: (AnyInjector) -> [K]
    private let lambdaResolve: (inout AnyInjector, Key) throws -> Providable
    #if swift(>=3.0)
    private let lambdaProvide: (inout AnyInjector, K, @escaping (inout AnyInjector) throws -> Providable) -> Void
    #else
    private let lambdaProvide: (inout AnyInjector, K, (inout AnyInjector) throws -> Providable) -> Void
    #endif

    #if swift(>=3.0)
    /**
     Initializes `AnyInjector` with a given `MutableInjector`.

     - Parameter injector: The `MutableInjector` that shall be wrapped.
     */
    public init<I: MutableInjector>(injector: I) where I.Key == K {
        self.injector = injector
        self.lambdaResolve = { (this: inout AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            return try injector.resolve(key: key)
        }
        self.lambdaProvide = { this, key, factory in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            injector.provide(key: key, usingFactory: { inj in
                var any = AnyInjector(injector: inj)
                return try factory(&any)
            })
        }

        self.lambdaRevoke = { (this: inout AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            injector.revoke(key: key)
        }

        self.lambdaKeys = { this in
            return (this.injector as! I).providedKeys
        }
    }
    #else
    /**
     Initializes `AnyInjector` with a given `MutableInjector`.

     - Parameter injector: The `MutableInjector` that shall be wrapped.
     */
    public init<I: MutableInjector where I.Key == K>(injector: I) {
        self.injector = injector
        self.lambdaResolve = { (inout this: AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            return try injector.resolve(key: key)
        }
        self.lambdaProvide = { this, key, factory in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            injector.provide(key: key, usingFactory: { inj in
                var any = AnyInjector(injector: inj)
                return try factory(&any)
            })
        }

        self.lambdaRevoke = { (inout this: AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            var injector = this.injector as! I
            defer { this.injector = injector }
            injector.revoke(key: key)
        }

        self.lambdaKeys = { this in
            return (this.injector as! I).providedKeys
        }
    }
    #endif

    #if swift(>=3.0)
    /**
     Initializes `AnyInjector` with a given `Injector`.

     - Parameter injector: The `Injector` that shall be wrapped.
     */
    public init<I: Injector>(injector: I) where I.Key == K {
        self.injector = injector
        self.lambdaResolve = { (this: inout AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            return try (this.injector as! I).resolving(key: key)
        }
        self.lambdaProvide = { this, key, factory in
            // swiftlint:disable:next force_cast
            let injector = this.injector as! I
            this.injector = injector.providing(key: key, usingFactory: { inj in
                var any = AnyInjector(injector: inj)
                return try factory(&any)
            })
        }

        self.lambdaRevoke = { (this: inout AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            let injector = this.injector as! I
            this.injector = injector.revoking(key: key)
        }

        self.lambdaKeys = { this in
            return (this.injector as! I).providedKeys
        }
    }
    #else
    /**
     Initializes `AnyInjector` with a given `Injector`.

     - Parameter injector: The `Injector` that shall be wrapped.
     */
    public init<I: Injector where I.Key == K>(injector: I) {
        self.injector = injector
        self.lambdaResolve = { (inout this: AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            return try (this.injector as! I).resolving(key: key)
        }
        self.lambdaProvide = { this, key, factory in
            // swiftlint:disable:next force_cast
            let injector = this.injector as! I
            this.injector = injector.providing(key: key, usingFactory: { inj in
                var any = AnyInjector(injector: inj)
                return try factory(&any)
            })
        }

        self.lambdaRevoke = { (inout this: AnyInjector, key: Key) in
            // swiftlint:disable:next force_cast
            let injector = this.injector as! I
            this.injector = injector.revoking(key: key)
        }

        self.lambdaKeys = { this in
            return (this.injector as! I).providedKeys
        }
    }
    #endif
    
    #if swift(>=3.0)
    /// See `MutableInjector.resolve(key:)`.
    public mutating func resolve(key: K) throws -> Providable {
        return try self.lambdaResolve(&self, key)
    }
    /// See `MutableInjector.provide(key:usingFactory:)`.
    public mutating func provide(
        key: K,
        usingFactory factory: @escaping (inout AnyInjector) throws -> Providable) {
        self.lambdaProvide(&self, key, factory)
    }
    #else
    /// See `MutableInjector.resolve(key:)`.
    public mutating func resolve(key key: K) throws -> Providable {
        return try self.lambdaResolve(&self, key)
    }
    /// See `MutableInjector.provide(key:usingFactory:)`.
    public mutating func provide(
        key key: K,
        usingFactory factory: (inout AnyInjector) throws -> Providable) {
        self.lambdaProvide(&self, key, factory)
    }
    #endif

    /// See `Injector.providedKeys`.
    public var providedKeys: [K] {
        return lambdaKeys(self)
    }

    #if swift(>=3.0)
    /// See `MutableInjector.revoke(key:)`.
    public mutating func revoke(key: K) {
        lambdaRevoke(&self, key)
    }
    #else
    /// See `MutableInjector.revoke(key:)`.
    public mutating func revoke(key key: K) {
        lambdaRevoke(&self, key)
    }
    #endif
}
