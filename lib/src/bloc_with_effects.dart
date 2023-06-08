import 'package:bloc_effects/src/effects_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template bloc}
/// [BlocWithEffects ] has the same behavior as [Bloc]
/// and add the [emitEffect] method to [Bloc] features.
/// {@endtemplate}
abstract class BlocWithEffects<Event, State, Effect> extends Bloc<Event, State>
    with Effects<Effect> {
  /// {@macro bloc}
  BlocWithEffects(super.initialState);
}
