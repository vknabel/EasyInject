/// Wraps a given `MutableInjector` in order to lose type details, but keeps it mutable.
/// - ToDo: Replace generic `I : Injector` with a `ProvidableKey`
public struct AnyMutableInjector<I: MutableInjector>: InjectorDerivingFromMutableInjector {
    public typealias Key = I.Key

    /// The internally used `Injector`.
    private var injector: I
    /**
     Initializes `AnyMutableInjector` with a given `MutableInjector`.

     - Parameter injector: The `MutableInjector` that shall be wrapped.
     */
    public init(injector: I) {
        self.injector = injector
    }

    public mutating func resolve<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        return try injector.resolve(from: provider)
    }
    public mutating func provide<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout AnyMutableInjector<I>) throws -> Value) {
        var this = self
        defer { self = this }
        injector.provide(for: provider, usingFactory: { newMutable -> Value in
            this.injector = newMutable
            return try factory(&this)
        })
    }
}
