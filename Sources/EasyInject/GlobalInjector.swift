/// Wraps a given `MutableInjector` in order to add reference semantics.
public final class GlobalInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector,
  MutableInjector
{
  public typealias Key = K

  /// The internally used `Injector`.
  private var injector: AnyInjector<K>

  /**
     Initializes `AnyInjector` with a given `Injector`.

     - Parameter injector: The `Injector` that shall be wrapped.
     */
  public init<I: Injector>(injector: I) where I.Key == Key {
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
  public func resolve(key: Key) throws -> Providable {
    return try injector.resolve(key: key)
  }

  /// Implements `MutableInjector.provide(key:usingFactory:)`
  public func provide(
    key: Key, usingFactory factory: @escaping (inout GlobalInjector) throws -> Providable
  ) {
    return self.injector.provide(key: key) { _ in
      var this = self
      return try factory(&this)
    }
  }

  /// See `MutableInjector.revoke(key:)`.
  public func revoke(key: K) {
    injector.revoke(key: key)
  }

  /// Implements `Injector.providedKeys` by passing the internal provided keys.
  public var providedKeys: [K] {
    return injector.providedKeys
  }
}

extension GlobalInjector {
  /// Creates a strict global injector.
  public convenience init() {
    self.init(injector: StrictInjector())
  }
}
