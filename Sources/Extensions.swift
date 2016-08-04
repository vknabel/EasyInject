
public extension MutableInjector {
    func globalize() -> GlobalInjector<Key> {
        return GlobalInjector(injector: self)
    }

    func erase() -> AnyInjector<Key> {
        return AnyInjector(injector: self)
    }

    func compose<I: MutableInjector where I.Key == Key>(_ right: I) -> ComposedInjector<Key> {
        return ComposedInjector(left: self, right: right)
    }
}

public extension Injector {
    func globalized() -> GlobalInjector<Key> {
        return GlobalInjector(injector: AnyInjector(injector: self))
    }

    func erased() -> AnyInjector<Key> {
        return AnyInjector(injector: self)
    }

    func composed<I: Injector where I.Key == Key>(_ right: I) -> ComposedInjector<Key> {
        return ComposedInjector(left: self, right: right)
    }
}
