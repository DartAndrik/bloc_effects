import 'package:bloc_effects/src/bloc_with_effects_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

class TestBlocObserver extends BlocWithEffectsObserver {
  TestBlocObserver(this.observedEffects);

  final Map<BlocBase<dynamic>, List<dynamic>> observedEffects;

  @override
  void onEffect<E>(BlocBase<dynamic> bloc, E effect) {
    observedEffects.putIfAbsent(bloc, () => []);
    observedEffects[bloc]!.add(effect);
    super.onEffect(bloc, effect);
  }
}

void main() {
  group('BlocWithEffectsObserver', () {
    group('onEffect', () {
      test('Emitted effects are observed correctly', () async {
        final bloc = TestBloc();
        final observedEffects = <BlocBase<dynamic>, List<dynamic>>{};
        final testBlocObserver = TestBlocObserver(observedEffects);
        Bloc.observer = testBlocObserver;

        expect(
          observedEffects,
          isEmpty,
          reason: 'No observed effects on creation',
        );

        bloc.add(const ButtonPressed());

        // Important: wait for a delay to trigger effect emission
        await Future<void>.delayed(Duration.zero);

        expect(
          observedEffects,
          {
            bloc: [isA<ShowSnackBar>()],
          },
          reason: 'ButtonPressed event, should trigger a ShowSnackBar effect',
        );
      });
    });
  });
}
