#0.3.0
*Released: 04/08/2016*

**Breaking API Changes:**

- Removed `AnyMutableInjector`, instead use `AnyInjector` - @vknabel
- `AnyInjector`, `GlobalInjector`, `ComposedInjector` now only depend on the `ProvidableKey` instead of complete `Injector`s
- `Injector` now requires `resolving(key:)` and `providing(key:,usingFactory:)`
- `MutableInjector` now requires `resolve(key:)` and `provide(key:,usingFactory:)`

**API Additions:**

- `AnyInjector` additionally conforms to `MutableInjector`
- Added `globalize()`, `erase()`, `compose(_:)` that wrap a `MutableInjector` into another one
- Added `globalized()`, `erased()`, `composed(_:)` that wrap a `Injector` into another one


**Other Changes:**

- The old methods `resolving(from:)`, `providing(for:,usingFactory:)` have been moved to an extension
- The old methods `resolve(from:)`, `provide(for:,usingFactory:)` have been moved to an extension
- `GlobalInjector` and `ComposedInjector` now use `AnyInjector` internally
- Reincluded docs into the repo
