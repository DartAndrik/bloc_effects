import 'dart:async';

/// An object that must be closed when no longer in use.
abstract class EffectsClosable {
  /// Closes the current instance.
  /// The returned future completes when the instance has been closed.
  FutureOr<void> closeEffects();

  /// Whether the object is closed.
  ///
  /// An object is considered closed once [closeEffects] is called.
  bool get isEffectsClosed;
}

/// An object that provides access to a stream of effects over time.
abstract class EffectsStreamable<T extends Object?> {
  /// The current [effectsStream] of states.
  Stream<T> get effectsStream;
}

/// An object that can emit new effects.
abstract class EffectsUsable<Effect extends Object?> {
  /// Emits a new [effect].
  void emitEffect(Effect effect);
}

/// A [EffectsStreamable] that must be closed when no longer in use.
abstract class EffectsController<Effect>
    implements EffectsStreamable<Effect>, EffectsClosable {}

/// An object that provides effect emitting behaviour to subclasses.
abstract class BaseEffector<Effect>
    implements EffectsController<Effect>, EffectsUsable<Effect> {}
