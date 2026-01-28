import 'package:bloc_effects/src/bloc_effect_listener.dart';
import 'package:bloc_effects/src/effects_mixin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template bloc_effect_consumer}
/// [BlocEffectConsumer] exposes a [builder] and [listener] in order react to
/// new states.
/// [BlocEffectConsumer] is analogous to a nested `BlocEffectListener`
/// and `BlocBuilder` but reduces the amount of boilerplate needed.
/// [BlocEffectConsumer] should only be used when it is necessary to both
/// rebuild UI and execute other reactions to effects in the [bloc].
///
/// [BlocEffectConsumer] takes a required `BlocWidgetBuilder`
/// and `BlocEffectListener` and an optional [bloc],
/// `BlocBuilderCondition`.
///
/// If the [bloc] parameter is omitted, [BlocEffectConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///
/// ```dart
/// BlocEffectConsumer<BlocA, BlocAState, BlocAEffect>(
///   listener: (context, effect) {
///     // do stuff here based on BlocA's effect
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [BlocEffectConsumer] rebuilds.
/// [buildWhen] should only be used for performance optimizations as it
/// provides no security about the state passed to the [builder] function.
/// [buildWhen] will be invoked on each [bloc] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
/// the [BlocEffectConsumer] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocEffectConsumer<BlocA, BlocAState, BlocAEffect>(
///   listener: (context, effect) {
///     // do stuff here based on BlocA's effect
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
class BlocEffectConsumer<B extends Effects<S, E>, S, E>
    extends StatelessWidget {
  /// {@macro bloc_effect_consumer}
  const BlocEffectConsumer({
    required this.builder,
    required this.listener,
    super.key,
    this.bloc,
    this.buildWhen,
  });

  /// The [bloc] that the [BlocConsumer] will interact with.
  /// If omitted, [BlocConsumer] will automatically perform a lookup using
  /// `BlocProvider` and the current `BuildContext`.
  final B? bloc;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [bloc] `effect`
  /// and is responsible for executing in response to `effect` changes.
  final EffectWidgetListener<E> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final BlocBuilderCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) {
    return BlocEffectListener<B, S, E>(
      listener: listener,
      effector: bloc,
      child: BlocBuilder<B, S>(
        bloc: bloc,
        builder: builder,
        buildWhen: buildWhen,
      ),
    );
  }
}
