import 'package:bloc_effects/src/base_effector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocWithEffects<Event, State, Effect> extends Bloc<Event, State>
    with Effector<State, Effect>
    implements BaseEffector<Effect> {
  BlocWithEffects(super.initialState);
}
