/// Wraps a given `MutableInjector` in order to add reference semantics.
public final class GlobalInjector<I: MutableInjector>: InjectorDerivingFromMutableInjector {
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

    public func copy() -> GlobalInjector<I> {
        return GlobalInjector(injector: injector)
    }

    public func resolve<Value: Providable>
        (from provider: Provider<Key, Value>) throws -> Value {
        return try injector.resolve(from: provider)
    }
    public func provide<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout GlobalInjector) throws -> Value) {
        return self.injector.provide(for: provider) { (injector: inout I) -> Value in
            var this = self
            defer { self.injector = this.injector }
            return try factory(&this)
        }
    }
}
