import 'dart:async';

import 'package:bloc_effects/src/effects_mixin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `effect`. It is responsible for executing in response
/// to new `effect` emitted. If the `state` snapshot is necessary
/// on the moment of `effect` emitting, you can provide it using the properties
/// of the effect class.
typedef EffectWidgetListener<Effect> = void Function(
  BuildContext,
  Effect,
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
/// BlocEffectListener<BlocA, BlocEffect>(
///   listener: (context, effect) {
///      // do stuff here based on BlocEffect with the bloc state snapshot stored in it(if it's necessary)
///      // on the moment of effect emitting
///   },
///   child: const SizedBox(),
/// )
/// ```
/// Only specify the [effector] if you wish to provide a [effector] that is
/// otherwise not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocEffectListener<BlocA, BlocEffect>(
///   effector: blocA,
///   listener: (context, effect) {
///     // do stuff here based on BlocEffect with the bloc state snapshot stored in it(if it's necessary)
///     // on the moment of effect emitting
///   },
///   child: const SizedBox(),
/// )
/// ```
/// {@endtemplate}
class BlocEffectListener<B extends Effects<E>, E> extends StatefulWidget {
  /// {@macro bloc_effect_listener}
  const BlocEffectListener({
    required this.listener,
    required this.child,
    this.effector,
    super.key,
  });

  /// The [effector] whose `effects` will be listened to.
  /// Whenever the [effector] emit new `effect`, [listener] will be invoked.
  final B? effector;

  /// The [EffectWidgetListener] which will be called on every `effect` emmit.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `effect` emit.
  final EffectWidgetListener<E> listener;

  /// The widget which will be rendered as a descendant of the
  /// [BlocEffectListener].
  final Widget child;

  @override
  State<BlocEffectListener<B, E>> createState() =>
      _BlocEffectListenerState<B, E>();
}

class _BlocEffectListenerState<B extends Effects<E>, E>
    extends State<BlocEffectListener<B, E>> {
  StreamSubscription<E>? _subscription;
  late B _effector;

  void _subscribe() {
    final context = this.context;

    _subscription = _effector.effectsStream.listen(
      (effect) {
        if (context.mounted) {
          widget.listener(context, effect);
        }
      },
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
    super.dispose();
  }

  @override
  void didUpdateWidget(BlocEffectListener<B, E> oldWidget) {
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
  Widget build(BuildContext context) => widget.child;
}
