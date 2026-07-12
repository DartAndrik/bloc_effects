import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An interface, witch add observing the effects using behavior
/// of [Bloc] instances.
abstract class BlocWithEffectsObserver extends BlocObserver {
  /// Creates an observer for blocs and their effects.
  const BlocWithEffectsObserver();

  /// Called whenever an [effect] is emitted from an effects implementation.
  ///
  /// Override [onBlocEffect] when the emitting bloc is required.
  @protected
  @mustCallSuper
  void onEffect<E>(E effect) {}

  /// Called whenever [bloc] emits an [effect].
  ///
  /// The default implementation delegates to [onEffect] so observers written
  /// for bloc_effects 2.x continue to receive effects.
  @protected
  @mustCallSuper
  void onBlocEffect(BlocBase<dynamic> bloc, Object? effect) {
    onEffect<Object?>(effect);
  }
}
