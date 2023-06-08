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
  });
}
