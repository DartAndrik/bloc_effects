import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An interface, witch add observing the effects using behavior
/// of [Bloc] instances.
abstract class BlocWithEffectsObserver extends BlocObserver {
  /// Called whenever an [effect] is `used` from any [BlocBase] implementation
  ///  with the given [effect].
  @protected
  @mustCallSuper
  void onEffect<E>(E effect) {}
}
