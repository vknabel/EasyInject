
public extension MutableInjector {
    /// Wraps `self` into a `GlobalInjector`.
    ///
    /// - Returns: `GlobalInjector` that wraps `self`.
    func globalize() -> GlobalInjector<Key> {
        return GlobalInjector(injector: self)
    }

    /// Erases the specific `MutableInjector` Type.
    ///
    /// - Returns: `AnyInjector` that wraps `self`.
    func erase() -> AnyInjector<Key> {
        return AnyInjector(injector: self)
    }

    /// Composes `self` with another given `MutableInjector`.
    ///
    /// - Parameter right: The secondary `MutableInjector`.
    /// - Returns: `AnyInjector` that wraps `self`.
    func compose<I: MutableInjector where I.Key == Key>(_ right: I) -> ComposedInjector<Key> {
        return ComposedInjector(left: self, right: right)
    }
}

public extension Injector {
    /// Wraps `self` into a `GlobalInjector`.
    ///
    /// - Returns: `GlobalInjector` that wraps `self`.
    func globalized() -> GlobalInjector<Key> {
        return GlobalInjector(injector: AnyInjector(injector: self))
    }

    /// Erases the specific `Injector` Type.
    ///
    /// - Returns: `AnyInjector` that wraps `self`.
    func erased() -> AnyInjector<Key> {
        return AnyInjector(injector: self)
    }

    /// Composes `self` with another given `Injector`.
    ///
    /// - Parameter right: The secondary `Injector`.
    /// - Returns: `AnyInjector` that wraps `self`.
    func composed<I: Injector where I.Key == Key>(_ right: I) -> ComposedInjector<Key> {
        return ComposedInjector(left: self, right: right)
    }
}
