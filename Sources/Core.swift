/// Declares that the type is seen as `Providable` through an `Injector`.
public protocol Providable { }

/// `Providable`s will be associated to `ProvidableKey`s.
public typealias ProvidableKey = Hashable

/// Adds type information to a `ProvidableKey`.
public struct Provider<K : ProvidableKey, V : Providable> {
    /// Type of `Providable`s that will be associated with `Provider.key`.
    public typealias Value = V
    /// Type of `ProvidableKey`s that shall be represented.
    public typealias Key = K

    /// The represented key of the `Provider`.
    public let key: K

    /**
     Initializes a generic `Provider` representing the given `ProviderKey`.

     - Parameter key: The represented `ProviderKey`.
     */
    public init(for key: K) {
        self.key = key
    }
}

/// Implements `Equatable` for all `Provider`s.
/// :nodoc:
public func ==<K: Hashable, V: Providable>(lhs: Provider<K, V>, rhs: Provider<K, V>) -> Bool {
    return lhs.key == rhs.key
}


/// A `Provider` that has been provided into an `Injector`.
public protocol InjectedProvider {
    /// Type of `Injector`s that shall be used when resolving.
    associatedtype Injected: Injector

    /// Resolves the value that has been associated with `self.key`.
    /// - Throws: `InjectionError<Key, Value>`
    /// - Returns: The resolved value.
    func resolve(withInjector injector: inout Injected) throws -> Providable

    /**
     Initializes an `InjectedProvider`

     - Parameter provider: `Provider` that has been provided while injection.
     - Parameter factory: A closure, that return the `value` to be injected.
     */
    init(key: Injected.Key,
        withInjector injector: inout Injected,
        usingFactory factory: @escaping (inout Injected) throws -> Providable)
}

/// Stores `Providable`s associated for corredponding `ProvidableKey`s
/// using `Provider`s and internally `InjectedProvider`s.
public protocol Injector {
    /// The required `ProvidableKey` for injection.
    associatedtype Key: ProvidableKey

    /**
     Resolves `InjectedProvider.value` for a given `Key`.

     - Parameter key: The `Key` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    func resolving(key: Key) throws -> Providable

    /**
     Creates an instance providing a value as a factory for a given `Key`.

     - ToDo: Improve markup for `factory`'s parameter

     - Parameter key: The `Key`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    func providing(key: Key, usingFactory factory: @escaping (inout Self) throws -> Providable) -> Self

    /// Creates a new instance that provides all keys except the given one.
    ///
    ///
    /// - Parameter key: The key that shall be removed.
    /// - Returns: A copy that doesn't contain key.
    func revoking(key: Key) -> Self

    /// Returns all Keys, that has been injected, regardless wether resolving fails.
    var providedKeys: [Key] { get }
}

/// An `Injector` that additionally is mutable.
public protocol MutableInjector: Injector {
    /**
     Additionally provides a value given as a factory for a given `Key`.

     - Parameter key: The `Key`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    mutating func provide(key: Key, usingFactory factory: @escaping (inout Self) throws -> Providable)

    /**
     Resolves `InjectedProvider.value` for a given `Key`.

     - Parameter key: The `Key` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    mutating func resolve(key: Key) throws -> Providable

    /// Ensures a given key is not provided anymoure.
    ///
    /// - Parameter key: The key that shall be removed.
    mutating func revoke(key: Key)
}

//: Errors

/// Errors, that may occur while resolving from a `Provider`.
public enum InjectionError<Key: ProvidableKey>: Error, Equatable {
    /// There has been no value provided with the `ProvidableKey`.
    case keyNotProvided(Key)
    /// The given `Provider`'s `Value`-type did not match with the stored one.
    /// - Note: When issue arised, you probably have defined two different `Provider`s
    /// using the same `key`, but a different `Value`-Type.
    case nonMatchingType(provided: Any, expected: Providable.Type)

    /// Any specific Error that may occur in your custom implementations.
    /// Will not be thrown by built-in `Injector`s.
    case customError(Error)

    /// Will be thrown if the dependency graph is recursive.
    case cyclicDependency(Key)

    /// Tests for equality.
    /// Ignores:
    ///     - `InjectionError.nonMatchingType(provided:expected:)`'s expected
    ///     - `InjectionError.customError(_)`'s parameter
    /// :nodoc:
    public static func ==<K: ProvidableKey>(lhs: InjectionError<K>, rhs: InjectionError<K>) -> Bool {
        switch (lhs, rhs) {
        case let (.keyNotProvided(lk), .keyNotProvided(rk)):
            return lk == rk
        case let (.nonMatchingType(_, le), .nonMatchingType(_, re)):
            return le == re
        case (.customError(_), .customError(_)):
            return true
        case let (.cyclicDependency(lhs), .cyclicDependency(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}
