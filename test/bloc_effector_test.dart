import 'dart:async';

import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

class DelayedEvent {
  const DelayedEvent();
}

class DelayedBloc extends BlocWithEffects<DelayedEvent, int, TestEffect> {
  DelayedBloc({required this.started, required this.release}) : super(0) {
    on<DelayedEvent>((event, emit) async {
      started.complete();
      await release.future;
      emitEffect(const ShowSnackBar(1));
    });
  }

  final Completer<void> started;
  final Completer<void> release;
}

void main() {
  group('emitEffect', () {
    test('throws StateError if cubit is closed', () {
      var didThrow = false;
      runZonedGuarded(() {
        final cubit = TestCubit();
        expectLater(
          cubit.effectsStream.map((event) => event.runtimeType),
          emitsInOrder(<Matcher>[equals(ShowSnackBar), emitsDone]),
        );
        cubit
          ..emitEffect(ShowSnackBar(cubit.state))
          ..close()
          ..emitEffect(ShowSnackBar(cubit.state));
      }, (error, _) {
        didThrow = true;
        expect(
          error,
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot use effects after calling close',
          ),
        );
      });
      expect(didThrow, isTrue);
    });

    test('drains an in-flight effect before closing', () async {
      final started = Completer<void>();
      final release = Completer<void>();
      final bloc = DelayedBloc(started: started, release: release);
      final effects = <TestEffect>[];
      final subscription = bloc.effectsStream.listen(effects.add);

      bloc.add(const DelayedEvent());
      await started.future;
      final closeFuture = bloc.close();
      release.complete();
      await closeFuture;

      expect(effects, hasLength(1));
      expect(effects.single, isA<ShowSnackBar>());
      await subscription.cancel();
    });

    test('concurrent close calls wait for the same paused stream', () async {
      final cubit = TestCubit();
      final subscription = cubit.effectsStream.listen((_) {})..pause();

      final firstClose = cubit.close();
      final secondClose = cubit.close();
      var completed = false;
      unawaited(firstClose.then((_) => completed = true));
      await Future<void>.delayed(Duration.zero);

      expect(identical(firstClose, secondClose), isTrue);
      expect(cubit.isClosed, isTrue);
      expect(completed, isFalse);

      subscription.resume();
      await firstClose;
      await secondClose;
      await subscription.cancel();
    });
  });
}
