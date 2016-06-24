/// Wraps a given `Injector` in order to lose type details.
/// - ToDo: Replace generic `I : Injector` with a `ProvidableKey`
public struct AnyInjector<I : Injector>: Injector {
    public typealias Key = I.Key

    /// The internally used `Injector`.
    private let injector: I
    /**
     Initializes `AnyInjector` with a given `Injector`.

     - Parameter injector: The `Injector` that shall be wrapped.
     */
    public init(injector: I) {
        self.injector = injector
    }

    public func resolving<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value {
        return try injector.resolving(from: provider)
    }
    public func providing<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout AnyInjector<I>) throws -> Value) -> AnyInjector<I> {
        let result = injector.providing(for: provider, usingFactory: { injector in
            var any = AnyInjector(injector: injector)
            return try factory(&any)
        })
        return AnyInjector(injector: result)
    }
}
