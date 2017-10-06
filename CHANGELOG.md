# Changelog

## 1.1.0
*Released: 2017-10-06*

### API Additions

- Generic subscripts for `Injector`. - @vknabel

### Other Changes

- Support for Swift 4.0 while retaining Swift 3 support. - @vknabel
- `Providable` is now a typealias for `Any`, what shouldn't break but silences Swift 4 warnings. - @vknabel

## 1.0.0
*Released: 2016-10-18*

### Breaking Changes

- Added new case `InjectionError.cyclicDependency` (#1). - @vknabel

### API Additions

- Added `GenericProvidableKey` which lets you define custom types in a typealias. - @vknabel
- Detection of cyclic dependencies in `LazyInjector` (#1). - @vknabel
- `Provider.derive(_:)` will now work for all `ExpressibleByStringLiteral where K.StringLiteralType == String` (previously only for `String`) - @vknabel

### Other Changes

- Added some basic guides to generated Jazzy docs - @vknabel

## 0.8.1
*Released: 2016-09-26*

### Other Changes

- Updated Docs - @vknabel

## 0.8.0
*Released: 2016-09-08*

### Breaking Changes

- Dropped Swift 2.x Support - @vknabel

## 0.7.0

*Released: 23/08/2016*

### Breaking Changes

- `ComposedInjector` throws an aggregated `InjectionError.keyNotFound(_)` as expected - @vknabel
- Removed enum case `InjectionError.invalidInjection(key:injected:expected:)` - @vknabel

### API Additions

- Added convenience `GlobalInjector.init()` - @vknabel
- Added `Injector.revoking(for:)` that takes a `Provider` - @vknabel
- Added `Injector.revoke(for:)` that takes a `Provider` - @vknabel

### Other Changes

- Added Unit Tests - @vknabel
- Set up Travis CI - @vknabel

## 0.6.0
*Released: 16/08/2016*

### Breaking Changes

- Updated Swift 3.0 to Beta 6 - @vknabel

### Other Changes

- Fixes some warnings in Swift 2 and 3 - @vknabel

## 0.5.0
*Released: 10/08/2016*

### Breaking Changes

- Added `Injector.revoking(key:)` - @vknabel
- Added `MutableInjector.revoke(key:)` - @vknabel

### API Additions

- `Injector.revoking(key:)` will be implemented by `InjectorDerivingFromMutableInjector` - @vknabel
- Added `revoke{Left|Right|Both}(key:)` and `revoking{Left|Right|Both}(key:)` to `ComposedInjector` - @vknabel

### Other Changes

- Updated descriptions in `README.md`, `EasyInject.podspec` and `Play.playground` - @vknabel

## 0.4.0
*Released: 09/08/2016*

### Breaking Changes

- Added `Injector.providedKeys` - @vknabel

### API Additions

- Added default implementation for value type for `InjectorDerivingFromMutableInjector.copy()` - @vknabel

### Other Changes

- Documented 100% - @vknabel
- Renamed `Changelog.md` to `CHANGELOG.md` - @vknabel

## 0.3.0
*Released: 04/08/2016*

### Breaking API Changes

- Removed `AnyMutableInjector`, instead use `AnyInjector` - @vknabel
- `AnyInjector`, `GlobalInjector`, `ComposedInjector` now only depend on the `ProvidableKey` instead of complete `Injector`s - @vknabel
- `Injector` now requires `resolving(key:)` and `providing(key:,usingFactory:)` - @vknabel
- `MutableInjector` now requires `resolve(key:)` and `provide(key:,usingFactory:)` - @vknabel

### API Additions

- `AnyInjector` additionally conforms to `MutableInjector` - @vknabel
- Added `globalize()`, `erase()`, `compose(_:)` that wrap a `MutableInjector` into another one - @vknabel
- Added `globalized()`, `erased()`, `composed(_:)` that wrap a `Injector` into another one - @vknabel


### Other Changes

- The old methods `resolving(from:)`, `providing(for:,usingFactory:)` have been moved to an extension - @vknabel
- The old methods `resolve(from:)`, `provide(for:,usingFactory:)` have been moved to an extension - @vknabel
- `GlobalInjector` and `ComposedInjector` now use `AnyInjector` internally - @vknabel
- Reincluded docs into the repo - @vknabel
