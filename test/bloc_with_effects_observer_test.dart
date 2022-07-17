import 'package:bloc_effects/src/bloc_with_effects_observer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

class TestBlocObserver extends BlocWithEffectsObserver {}

void main() {
  final cubit = TestCubit();

  group('BlocWithEffectsObserver', () {
    group('onEffect', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        TestBlocObserver().onEffect(cubit, const ShowSnackBar());
      });
    });
  });
}
