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

public func ==<K: Hashable, V: Providable>(lhs: Provider<K, V>, rhs: Provider<K, V>) -> Bool {
    return lhs.key == rhs.key
}


/// A `Provider` that has been provided into an `Injector`.
public protocol InjectedProvider {
    /// Type of `Providable`s that will be associated with `Provider.key`.
    associatedtype Value: Providable
    /// Type of `Injector`s that shall be used when resolving.
    associatedtype Injected: Injector

    /// Resolves the value that has been associated with `self.key`.
    /// - Throws: `InjectionError<Key, Value>`
    /// - Returns: The resolved value.
    func resolve(withInjector injector: inout Injected) throws -> Value

    /**
     Initializes an `InjectedProvider`

     - Parameter provider: `Provider` that has been provided while injection.
     - Parameter factory: A closure, that return the `value` to be injected.
     */
    init(
        provider: Provider<Injected.Key, Value>,
        withInjector injector: inout Injected,
        usingFactory factory: (inout Injected) throws -> Value)
}

/// Stores `Providable`s associated for corredponding `ProvidableKey`s
/// using `Provider`s and internally `InjectedProvider`s.
public protocol Injector {
    /// The required `ProvidableKey` for injection.
    associatedtype Key: ProvidableKey
    /**
     Resolves `InjectedProvider.value` for a given `Provider`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    func resolving<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value
    /**
     Creates an instance providing a value as a factory for a given `Provider`.

     - ToDo: Improve markup for `factory`'s parameter

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     - Returns: A new `Injector` with contents of `self` and the newly provided value.
     */
    func providing<Value: Providable>(
        for provider: Provider<Key, Value>,
        usingFactory factory: (inout Self) throws -> Value) -> Self
}

/// An `Injector` that additionally is mutable.
public protocol MutableInjector: Injector {
    /**
     Additionally provides a value given as a factory for a given `Provider`.

     - Parameter provider: The `Provider`, an `InjectedProvider` is constructed of.
     - Parameter factory: Creates a value out of a new `Injector`.
     */
    mutating func provide
        <Value: Providable>
        (for provider: Provider<Key, Value>, usingFactory factory: (inout Self) throws -> Value)
    /**
     Resolves `InjectedProvider.value` for a given `Provider`.

     - Parameter provider: The `Provider` that has been used previously.
     - Returns: The previously added `Providable`.
     - Throws: `InjectionError`
     */
    mutating func resolve<Value: Providable>(from provider: Provider<Key, Value>) throws -> Value
}

//: Errors

/// Errors, that may occur while resolving from a `Provider`.
/// - ToDo: Implement `case cyclicDependency`
public enum InjectionError<Key: ProvidableKey>: ErrorProtocol {
    /// There has been no value provided with the `ProvidableKey`.
    case keyNotProvided(Key)
    /// The given `Provider`'s `Value`-type did not match with the stored one.
    /// - Note: When issue arised, you probably have defined two different `Provider`s
    /// using the same `key`, but a different `Value`-Type.
    case nonMatchingType(provided: Any, expected: Providable.Type)

    /// Any specific Error that may occur in your custom implementations.
    /// Will not be thrown by built-in `Injector`s.
    case customError(ErrorProtocol)
}
