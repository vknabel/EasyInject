extension MutableInjector {
  /// Wraps `self` into a `GlobalInjector`.
  ///
  /// - Returns: `GlobalInjector` that wraps `self`.
  public func globalize() -> GlobalInjector<Key> {
    return GlobalInjector(injector: self)
  }

  /// Erases the specific `MutableInjector` Type.
  ///
  /// - Returns: `AnyInjector` that wraps `self`.
  public func erase() -> AnyInjector<Key> {
    return AnyInjector(injector: self)
  }

  /// Composes `self` with another given `MutableInjector`.
  ///
  /// - Parameter right: The secondary `MutableInjector`.
  /// - Returns: `AnyInjector` that wraps `self`.
  public func compose<I: MutableInjector>(_ right: I) -> ComposedInjector<Key> where I.Key == Key {
    return ComposedInjector(left: self, right: right)
  }
}

extension Injector {
  /// Wraps `self` into a `GlobalInjector`.
  ///
  /// - Returns: `GlobalInjector` that wraps `self`.
  public func globalized() -> GlobalInjector<Key> {
    return GlobalInjector(injector: AnyInjector(injector: self))
  }

  /// Erases the specific `Injector` Type.
  ///
  /// - Returns: `AnyInjector` that wraps `self`.
  public func erased() -> AnyInjector<Key> {
    return AnyInjector(injector: self)
  }

  /// Composes `self` with another given `Injector`.
  ///
  /// - Parameter right: The secondary `Injector`.
  /// - Returns: `AnyInjector` that wraps `self`.
  public func composed<I: Injector>(_ right: I) -> ComposedInjector<Key> where I.Key == Key {
    return ComposedInjector(left: self, right: right)
  }
}
