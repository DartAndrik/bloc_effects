import 'dart:async';

import 'package:bloc_effects/src/base_effector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef EffectWidgetListener<Effect, State> = void Function(
  BuildContext,
  Effect,
  State,
);

class BlocEffectListener<B extends Effector<S, E>, E, S>
    extends StatefulWidget {
  const BlocEffectListener({
    required this.listener,
    required this.child,
    this.effector,
    Key? key,
  }) : super(key: key);

  final B? effector;
  final EffectWidgetListener<E, S> listener;
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
