import 'package:bloc_effects/src/base_effector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template bloc}
/// [BlocWithEffects ] has the same behavior as [Bloc]
/// and add the [useEffect] method to [Bloc] features.
/// {@endtemplate}
abstract class BlocWithEffects<Event, State, Effect> extends Bloc<Event, State>
    with Effector<State, Effect>
    implements BaseEffector<Effect> {
  /// {@macro bloc}
  BlocWithEffects(super.initialState);
}
