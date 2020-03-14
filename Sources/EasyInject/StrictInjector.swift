/// A basic implementation of `MutableInjector` that evaluates all factories on provide.
public struct StrictInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
  public typealias Key = K
  private var strictProviders: [K: Any] = [:]

  /// Creates an empty `StrictInjector`.
  public init() {}

  /// See `MutableInjector.resolve(key:)`.
  public mutating func resolve(key: Key) throws -> Providable {
    guard let untyped = strictProviders[key]
    else { throw InjectionError<Key>.keyNotProvided(key) }
    let typed = untyped as! StrictlyInjectedProvider<StrictInjector>
    return try typed.resolve(withInjector: &self)
  }

  /// See `MutableInjector.provide(key:usingFactory:)`.
  public mutating func provide(
    key: K, usingFactory factory: @escaping (inout StrictInjector) throws -> Providable
  ) {
    strictProviders[key] = StrictlyInjectedProvider(
      key: key,
      withInjector: &self,
      usingFactory: factory)
  }

  /// See `MutableInjector.revoke(key:)`.
  public mutating func revoke(key: K) {
    strictProviders.removeValue(forKey: key)
  }

  /// See `Injector.providedKeys`.
  public var providedKeys: [K] {
    return Array(strictProviders.keys)
  }
}
