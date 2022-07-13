import 'package:bloc_effects/src/base_effector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CubitWithEffects<State, Effect> extends Cubit<State>
    with Effector<State, Effect>
    implements BaseEffector<Effect> {
  CubitWithEffects(super.initialState);
}
