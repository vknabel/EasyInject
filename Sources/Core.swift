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

    #if swift(>=3.0)
    /// Resolves the value that has been associated with `self.key`.
    /// - Throws: `InjectionError<Key, Value>`
    /// - Returns: The resolved value.
    func resolve(withInjector injector: inout Injected) throws -> Providable
    #else
    /// Resolves the value that has been associated with `self.key`.
    /// - Throws: `InjectionError<Key, Value>`
    /// - Returns: The resolved value.
    func resolve(inout withInjector injector: Injected) throws -> Providable
    #endif

    #if swift(>=3.0)
    /**
     Initializes an `InjectedProvider`

     - Parameter provider: `Provider` that has been provided while injection.
     - Parameter factory: A closure, that return the `value` to be injected.
     */
    init(key: Injected.Key,
        withInjector injector: inout Injected,
        usingFactory factory: @escaping (inout Injected) throws -> Providable)
    #else
    /**
     Initializes an `InjectedProvider`

     - Parameter provider: `Provider` that has been provided while injection.
     - Parameter factory: A closure, that return the `value` to be injected.
     */
    init(key: Injected.Key,
        inout withInjector injector: Injected,
        usingFactory factory: (inout Injected) throws -> Providable)
    #endif
}

/// Stores `Providable`s associated for corredponding `ProvidableKey`s
/// using `Provider`s and internally `InjectedProvider`s.
public protocol Injector {
    /// The required `ProvidableKey` for injection.
    associatedtype Key: ProvidableKey

    #if swift(>=3.0)
    /**
     Resolves `InjectedProvider.value` for a given `Key`.

     - Parameter key: The `Key` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    func resolving(key: Key) throws -> Providable
    #else
    /**
     Resolves `InjectedProvider.value` for a given `Key`.

     - Parameter key: The `Key` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    func resolving(key key: Key) throws -> Providable
    #endif

    #if swift(>=3.0)
    /**
     Creates an instance providing a value as a factory for a given `Key`.

     - ToDo: Improve markup for `factory`'s parameter

     - Parameter key: The `Key`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    func providing(key: Key, usingFactory factory: @escaping (inout Self) throws -> Providable) -> Self
    #else
    /**
     Creates an instance providing a value as a factory for a given `Key`.

     - ToDo: Improve markup for `factory`'s parameter

     - Parameter key: The `Key`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    func providing(key key: Key, usingFactory factory: (inout Self) throws -> Providable) -> Self
    #endif

    #if swift(>=3.0)
    /// Creates a new instance that provides all keys except the given one.
    ///
    ///
    /// - Parameter key: The key that shall be removed.
    /// - Returns: A copy that doesn't contain key.
    func revoking(key: Key) -> Self
    #else
    /// Creates a new instance that provides all keys except the given one.
    ///
    ///
    /// - Parameter key: The key that shall be removed.
    /// - Returns: A copy that doesn't contain key.
    func revoking(key key: Key) -> Self
    #endif

    /// Returns all Keys, that has been injected, regardless wether resolving fails.
    var providedKeys: [Key] { get }
}

/// An `Injector` that additionally is mutable.
public protocol MutableInjector: Injector {
    #if swift(>=3.0)
    /**
     Additionally provides a value given as a factory for a given `Key`.

     - Parameter key: The `Key`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    mutating func provide(key: Key, usingFactory factory: @escaping (inout Self) throws -> Providable)
    #else
    /**
     Additionally provides a value given as a factory for a given `Key`.

     - Parameter key: The `Key`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    mutating func provide(key key: Key, usingFactory factory: (inout Self) throws -> Providable)
    #endif

    #if swift(>=3.0)
    /**
     Resolves `InjectedProvider.value` for a given `Key`.

     - Parameter key: The `Key` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    mutating func resolve(key: Key) throws -> Providable
    #else
    /**
     Resolves `InjectedProvider.value` for a given `Key`.

     - Parameter key: The `Key` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    mutating func resolve(key key: Key) throws -> Providable
    #endif

    #if swift(>=3.0)
    /// Ensures a given key is not provided anymoure.
    ///
    /// - Parameter key: The key that shall be removed.
    mutating func revoke(key: Key)
    #else
    /// Ensures a given key is not provided anymoure.
    ///
    /// - Parameter key: The key that shall be removed.
    mutating func revoke(key key: Key)
    #endif
}

//: Errors

#if swift(>=3.0)
#else
typealias Error = ErrorType
#endif

/// Errors, that may occur while resolving from a `Provider`.
/// - ToDo: Implement `case cyclicDependency`
public enum InjectionError<Key: ProvidableKey>: Error, Equatable {
    #if swift(>=3.0)
    #else
    public typealias Error = ErrorType
    #endif

    /// There has been no value provided with the `ProvidableKey`.
    case keyNotProvided(Key)
    /// The given `Provider`'s `Value`-type did not match with the stored one.
    /// - Note: When issue arised, you probably have defined two different `Provider`s
    /// using the same `key`, but a different `Value`-Type.
    case nonMatchingType(provided: Any, expected: Providable.Type)

    /// Any specific Error that may occur in your custom implementations.
    /// Will not be thrown by built-in `Injector`s.
    case customError(Error)
}

/// Tests for equality.
/// Ignores: 
///     - `InjectionError.nonMatchingType(provided:expected:)`'s expected
///     - `InjectionError.customError(_)`'s parameter
public func ==<K: ProvidableKey>(lhs: InjectionError<K>, rhs: InjectionError<K>) -> Bool {
    switch (lhs, rhs) {
    case let (.keyNotProvided(lk), .keyNotProvided(rk)):
        return lk == rk
    case let (.nonMatchingType(_, le), .nonMatchingType(_, re)):
        return le == re
    case (.customError(_), .customError(_)):
        return true
    default:
        return false
    }
}
