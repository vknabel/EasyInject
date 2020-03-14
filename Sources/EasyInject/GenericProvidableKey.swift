/// A generic implementation of `ProvidableKey`.
/// It may be used in your applications to get rid of stringly typed properties or keys.
///
/// Typically you will declare empty types for each use case.
/// These empty types are only used in order to fulfill constraints.
///
/// ```swift
/// enum ServicesKeyType { } // will never be instantiated
/// typealias Services = GenericProvidableKey<Services>
///
/// let serviceInjector = LazyInjector<Services>().globalize().erase()
/// serviceInjector // only Services will fit in here
/// ```
///
public struct GenericProvidableKey<T>: ProvidableKey, RawRepresentable, ExpressibleByStringLiteral,
  CustomStringConvertible, CustomDebugStringConvertible
{
  /// The name of the represented key.
  public let name: String

  /// Initializes a new `GenericProvidableKey`.
  ///
  /// - Parameter name: The name of the key.
  public init(name: String) {
    self.name = name
  }

  public var description: String {
    return name
  }

  public var debugDescription: String {
    return "\(T.self).\(name)"
  }
}

extension GenericProvidableKey {
  public var rawValue: String {
    return name
  }

  public init?(rawValue: String) {
    self.name = rawValue
  }
}

extension GenericProvidableKey {
  public var hashValue: Int {
    return rawValue.hashValue
  }

  public static func == (lhs: GenericProvidableKey, rhs: GenericProvidableKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

extension GenericProvidableKey {
  public init(stringLiteral value: String) {
    self.init(name: value)
  }

  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }

  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
}
