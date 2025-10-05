import 'dart:async';

import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'base_effector.dart';

/// Mixin [Effects] provides implementation for [BaseEffector]
mixin Effects<E> on Closable implements BaseEffector<E> {
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
  void emitEffect(E effect) {
    if (!isEffectsClosed) {}

    if (isClosed || isEffectsClosed) {
      throw StateError('Cannot use effects after calling close');
    }

    // ignore: invalid_use_of_protected_member
    _effectsBlocObserver?.onEffect(effect);
    _effectController.add(effect);
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
