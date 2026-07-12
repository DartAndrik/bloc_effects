import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

class TestBlocObserver extends BlocWithEffectsObserver {
  TestBlocObserver(this.observedEffects);

  final Map<BlocBase<dynamic>, List<dynamic>> observedEffects;

  @override
  void onBlocEffect(BlocBase<dynamic> bloc, Object? effect) {
    observedEffects.putIfAbsent(bloc, () => []);
    observedEffects[bloc]!.add(effect);
    super.onBlocEffect(bloc, effect);
  }
}

class LegacyBlocObserver extends BlocWithEffectsObserver {
  LegacyBlocObserver(this.observedEffects);

  final List<Object?> observedEffects;

  @override
  void onEffect<E>(E effect) {
    observedEffects.add(effect);
    super.onEffect<E>(effect);
  }
}

class TestClosable implements Closable {
  bool _isClosed = false;

  @override
  bool get isClosed => _isClosed;

  @override
  Future<void> close() async => _isClosed = true;
}

class StandaloneEffects extends TestClosable with Effects<String> {
  void emit(String effect) => emitEffect(effect);
}

void main() {
  group('BlocWithEffectsObserver', () {
    group('onEffect', () {
      test('Emitted effects are observed correctly', () async {
        final originalObserver = Bloc.observer;
        final observedEffects = <BlocBase<dynamic>, List<dynamic>>{};
        final testBlocObserver = TestBlocObserver(observedEffects);
        Bloc.observer = testBlocObserver;
        addTearDown(() => Bloc.observer = originalObserver);
        final bloc = TestBloc();
        addTearDown(bloc.close);

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

      test('legacy onEffect overrides continue to receive effects', () {
        final originalObserver = Bloc.observer;
        final observedEffects = <Object?>[];
        Bloc.observer = LegacyBlocObserver(observedEffects);
        addTearDown(() => Bloc.observer = originalObserver);
        final cubit = TestCubit();
        addTearDown(cubit.close);

        cubit.showSnackBar();

        expect(observedEffects, <Object?>[isA<ShowSnackBar>()]);
      });

      test('observes effects emitted outside a BlocBase', () {
        final originalObserver = Bloc.observer;
        final observedEffects = <Object?>[];
        Bloc.observer = LegacyBlocObserver(observedEffects);
        addTearDown(() => Bloc.observer = originalObserver);
        final effects = StandaloneEffects();
        addTearDown(effects.close);

        effects.emit('standalone effect');

        expect(observedEffects, <Object?>['standalone effect']);
      });
    });
  });
}
