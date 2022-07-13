import 'package:bloc_effects/src/base_effector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template cubit}
/// A [CubitWithEffects] is similar to [Cubit] but
/// also allows to call method [useEffect] for emitting events on UI.
///
/// Every [CubitWithEffects] can be also configured with an initial state
///
/// ```dart
/// class CounterCubit extends CubitWithEffects<int, SomeEffect> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
///
///   void onButtonPress() => useEffect(const SomeEffect());
/// }
/// ```
///
/// {@endtemplate}
abstract class CubitWithEffects<State, Effect> extends Cubit<State>
    with Effector<State, Effect>
    implements BaseEffector<Effect> {
  /// {@macro cubit}
  CubitWithEffects(super.initialState);
}
