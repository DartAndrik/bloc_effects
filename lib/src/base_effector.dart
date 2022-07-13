import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EffectsClosable {
  FutureOr<void> closeEffects();

  bool get isEffectsClosed;
}

abstract class EffectsStreamable<T extends Object?> {
  Stream<T> get effectsStream;
}

abstract class EffectsUsable<Effect extends Object?> {
  void useEffect(Effect effect);
}

abstract class EffectsController<Effect>
    implements EffectsStreamable<Effect>, EffectsClosable {}

abstract class BaseEffector<Effect>
    implements EffectsController<Effect>, EffectsUsable<Effect> {}

mixin Effector<S, E> on BlocBase<S> implements BaseEffector<E> {
  late final _effectController = StreamController<E>.broadcast();

  bool get hasListeners => _effectController.hasListener;

  @override
  Stream<E> get effectsStream => _effectController.stream;

  @override
  bool get isEffectsClosed => _effectController.isClosed;

  @override
  void useEffect(E effect) {
    if (!isEffectsClosed) {
      _effectController.add(effect);
    }
  }

  @override
  Future<void> closeEffects() async {
    await _effectController.close();
  }

  @override
  Future<void> close() {
    closeEffects();
    return super.close();
  }
}
