## 1.0.1
- Fix example to use mixin
## 1.0.0
- Breaking changes: the [Effector] mixin renamed to [Effects] mixin and it becomes public
and alternative way use effects in blocs and cubits to extends them from [BlocWithEffects] or [CubitWithEffects] classes.
- Breaking changes: separated Bloc state from Effects, removed from [BlocEffectListener], use state properties or snapshot 
as a part of Effect implementation.
- [flutter_bloc] updated to 8.1.3
- bump [sdk] high version to 4.0.0

## 0.3.0
- Breaking changes: the [useEffect] method had the same prefix name as hooks and was renamed to [emitEffect].
- [flutter_bloc] updated to 8.1.2

## 0.2.1
- Removed deprecated for Bloc methods.

## 0.2.0
- Added [BlocWithEffectsObserver] with [onEffect] callback
- [useEffect] throws [StateError] if bloc is closed
 
## 0.1.1
- Updated documentation, example, readme [README.md]
 
## 0.1.0
- updated [README.md]

## 0.1.0-dev.1
- initial release.
