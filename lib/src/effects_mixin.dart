import 'dart:async';

import 'package:bloc_effects/src/bloc_with_effects_observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'base_effector.dart';

/// Mixin [Effects] provides implementation for [BaseEffector]
mixin Effects<E> on Closable implements BaseEffector<E> {
  late final _effectController = StreamController<E>.broadcast();
  Future<void>? _effectsCloseFuture;
  Future<void>? _closeFuture;

  static BlocWithEffectsObserver? _resolveEffectsBlocObserver() {
    final observer = Bloc.observer;
    return observer is BlocWithEffectsObserver ? observer : null;
  }

  final BlocWithEffectsObserver? _effectsBlocObserver =
      _resolveEffectsBlocObserver();

  @override
  Stream<E> get effectsStream => _effectController.stream;

  @override
  bool get isEffectsClosed => _effectController.isClosed;

  void _notifyEffectObserver(E effect) {
    final observer = _effectsBlocObserver;
    if (observer == null) return;

    final Object source = this;
    if (source is BlocBase<dynamic>) {
      // ignore: invalid_use_of_protected_member
      observer.onBlocEffect(source, effect);
    } else {
      // ignore: invalid_use_of_protected_member
      observer.onEffect<E>(effect);
    }
  }

  @protected
  @visibleForTesting
  @override
  void emitEffect(E effect) {
    if (isClosed || isEffectsClosed) {
      throw StateError('Cannot use effects after calling close');
    }

    _effectController.add(effect);
    _notifyEffectObserver(effect);
  }

  @protected
  @mustCallSuper
  @override
  Future<void> closeEffects() {
    return _effectsCloseFuture ??= _effectController.close();
  }

  @mustCallSuper
  @override
  Future<void> close() {
    return _closeFuture ??= _close();
  }

  Future<void> _close() async {
    try {
      await super.close();
    } finally {
      await closeEffects();
    }
  }
}
