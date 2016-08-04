#0.3.0
*Released: 04/08/2016*

**Breaking API Changes:**

- Removed `AnyMutableInjector`, instead use `AnyInjector` - @vknabel
- `AnyInjector`, `GlobalInjector`, `ComposedInjector` now only depend on the `ProvidableKey` instead of complete `Injector`s - @vknabel
- `Injector` now requires `resolving(key:)` and `providing(key:,usingFactory:)` - @vknabel
- `MutableInjector` now requires `resolve(key:)` and `provide(key:,usingFactory:)` - @vknabel

**API Additions:**

- `AnyInjector` additionally conforms to `MutableInjector` - @vknabel
- Added `globalize()`, `erase()`, `compose(_:)` that wrap a `MutableInjector` into another one - @vknabel
- Added `globalized()`, `erased()`, `composed(_:)` that wrap a `Injector` into another one - @vknabel


**Other Changes:**

- The old methods `resolving(from:)`, `providing(for:,usingFactory:)` have been moved to an extension - @vknabel
- The old methods `resolve(from:)`, `provide(for:,usingFactory:)` have been moved to an extension - @vknabel
- `GlobalInjector` and `ComposedInjector` now use `AnyInjector` internally - @vknabel
- Reincluded docs into the repo - @vknabel
