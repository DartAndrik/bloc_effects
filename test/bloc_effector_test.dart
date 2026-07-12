import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

void main() {
  group('emitEffect', () {
    test('rejects effects as soon as close is called', () async {
      final cubit = TestCubit();
      final subscription = cubit.effectsStream.listen((_) {})..pause();

      cubit.emitEffect(ShowSnackBar(cubit.state));
      final closeFuture = cubit.close();

      expect(
        () => cubit.emitEffect(ShowSnackBar(cubit.state)),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot use effects after calling close',
          ),
        ),
      );

      subscription.resume();
      await closeFuture;
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
