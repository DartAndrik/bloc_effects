import 'dart:async';

import 'package:bloc_effects/src/bloc_with_effects_observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  void useEffect(Effect effect);
}

/// A [EffectsStreamable] that must be closed when no longer in use.
abstract class EffectsController<Effect>
    implements EffectsStreamable<Effect>, EffectsClosable {}

/// An object that provides effect emitting behaviour to subclasses.
abstract class BaseEffector<Effect>
    implements EffectsController<Effect>, EffectsUsable<Effect> {}

/// Mixin [Effector] provides implementation for [BaseEffector]
mixin Effector<S, E> on BlocBase<S> implements BaseEffector<E> {
  late final _effectController = StreamController<E>.broadcast();

  BlocWithEffectsObserver? get _effectsBlocObserver {
    final observer = Bloc.observer;
    return observer is BlocWithEffectsObserver ? observer : null;
  }

  @override
  Stream<E> get effectsStream => _effectController.stream;

  @override
  bool get isEffectsClosed => _effectController.isClosed;

  @protected
  @visibleForTesting
  @override
  void useEffect(E effect) {
    if (!isEffectsClosed) {}
    try {
      if (isClosed || isEffectsClosed) {
        throw StateError('Cannot use effects after calling close');
      }

      // ignore: invalid_use_of_protected_member
      _effectsBlocObserver?.onEffect(this, effect);
      _effectController.add(effect);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @protected
  @mustCallSuper
  @override
  Future<void> closeEffects() async {
    await _effectController.close();
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    if (!isEffectsClosed) {
      await closeEffects();
    }
    await super.close();
  }
}
