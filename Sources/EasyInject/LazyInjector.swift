/// A basic implementation of `MutableInjector` that evaluates all factories on resolve.
public struct LazyInjector<K: ProvidableKey>: InjectorDerivingFromMutableInjector {
  public typealias Key = K

  private var lazyProviders: [K: AnyObject] = [:]

  /// Creates an empty `StrictInjector`.
  public init() {}

  /// See `MutableInjector.resolve(key:)`.
  public mutating func resolve(key: Key) throws -> Providable {
    guard let untyped = lazyProviders[key]
    else { throw InjectionError<Key>.keyNotProvided(key) }
    let typed = untyped as! LazilyInjectedProvider<LazyInjector>
    return try typed.resolve(withInjector: &self)
  }

  /// See `MutableInjector.provide(key:usingFactory:)`.
  public mutating func provide(
    key: K, usingFactory factory: @escaping (inout LazyInjector<K>) throws -> Providable
  ) {
    lazyProviders[key] = LazilyInjectedProvider(
      key: key,
      withInjector: &self,
      usingFactory: factory)
  }

  /// See `MutableInjector.revoke(key:)`.
  public mutating func revoke(key: K) {
    lazyProviders.removeValue(forKey: key)
  }

  /// See `Injector.providedKeys`.
  public var providedKeys: [K] {
    return Array(lazyProviders.keys)
  }
}
