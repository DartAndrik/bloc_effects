import 'dart:async';

import 'package:bloc_effects/src/base_effector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `effect` and `state`. It is responsible for executing in response
/// to new `effect` emitted. The `state` is the snapshot of state
/// on the moment of `effect` emitting.
typedef EffectWidgetListener<Effect, State> = void Function(
  BuildContext,
  Effect,
  State,
);

/// {@template bloc_effect_listener}
/// Takes a [EffectWidgetListener] and an optional [effector] and invokes
/// the [listener] in response to `effect` emitting in the [effector].
/// It should be used for functionality that needs to occur only in response to
/// a `effect` such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `effect`.
///
/// If the [effector] parameter is omitted, [BlocEffectListener] will
/// automatically perform a lookup using [BlocProvider] and
/// the current `BuildContext`.
///
/// ```dart
/// BlocEffectListener<BlocA, BlocEffect, BlocAState>(
///   listener: (context, effect, state) {
///      // do stuff here based on BlocEffect and BlocA's state snapshot
///      // on the moment of effect emitting
///   },
///   child: const SizedBox(),
/// )
/// ```
/// Only specify the [effector] if you wish to provide a [effector] that is
/// otherwise not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocEffectListener<BlocA, BlocEffect, BlocAState>(
///   effector: blocA,
///   listener: (context, effect, state) {
///     // do stuff here based on BlocEffect and BlocA's state snapshot
///     // on the moment of effect emitting
///   },
///   child: const SizedBox(),
/// )
/// ```
/// {@endtemplate}
class BlocEffectListener<B extends Effector<S, E>, E, S>
    extends StatefulWidget {
  /// {@macro bloc_effect_listener}
  const BlocEffectListener({
    required this.listener,
    required this.child,
    this.effector,
    Key? key,
  }) : super(key: key);

  /// The [effector] whose `effects` will be listened to.
  /// Whenever the [effector] emit new `effect`, [listener] will be invoked.
  final B? effector;

  /// The [EffectWidgetListener] which will be called on every `effect` emmit.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `effect` emit.
  final EffectWidgetListener<E, S> listener;

  /// The widget which will be rendered as a descendant of the
  /// [BlocEffectListener].
  final Widget child;

  @override
  State<BlocEffectListener<B, E, S>> createState() =>
      _BlocEffectListenerState<B, E, S>();
}

class _BlocEffectListenerState<B extends Effector<S, E>, E, S>
    extends State<BlocEffectListener<B, E, S>> {
  StreamSubscription<E>? _subscription;
  late B _effector;

  void _subscribe() {
    _subscription = _effector.effectsStream.listen(
      (effect) => widget.listener(context, effect, _effector.state),
    );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void initState() {
    super.initState();
    _effector = widget.effector ?? context.read<B>();
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    _effector.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(BlocEffectListener<B, E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEffector = oldWidget.effector ?? context.read<B>();
    final currentEffector = widget.effector ?? oldEffector;
    if (oldEffector != currentEffector) {
      if (_subscription != null) {
        _unsubscribe();
        _effector = currentEffector;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final effector = widget.effector ?? context.read<B>();
    if (_effector != effector) {
      if (_subscription != null) {
        _unsubscribe();
        _effector = effector;
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
