import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

void main() {
  group('emitEffect', () {
    test('throws StateError if cubit is closed', () {
      var didThrow = false;
      runZonedGuarded(() {
        final cubit = TestCubit();
        expectLater(
          cubit.effectsStream,
          emitsInOrder(<Matcher>[equals(const ShowSnackBar()), emitsDone]),
        );
        cubit
          ..emitEffect(const ShowSnackBar())
          ..close()
          ..emitEffect(const ShowSnackBar());
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
  });
}
