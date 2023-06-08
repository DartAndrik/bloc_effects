import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class TestEffect {}

class ShowSnackBar implements TestEffect {
  const ShowSnackBar(this.stateValue);

  final int stateValue;
}

abstract class TestEvent {}

class ButtonPressed implements TestEvent {
  const ButtonPressed();
}

class TestCubit extends CubitWithEffects<int, TestEffect> {
  TestCubit({int value = 0}) : super(value);

  void showSnackBar() => emitEffect(ShowSnackBar(state));

  void increment() {
    emit(state + 1);
  }
}

class TestBloc extends BlocWithEffects<TestEvent, int, TestEffect> {
  TestBloc({int value = 0}) : super(value) {
    on<ButtonPressed>(_onButtonPressed);
  }

  void _onButtonPressed(ButtonPressed event, Emitter<int> emit) =>
      emitEffect(ShowSnackBar(state));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.onListenerCalled}) : super(key: key);

  final EffectWidgetListener<TestEffect>? onListenerCalled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TestCubit _testCubit;

  @override
  void initState() {
    super.initState();
    _testCubit = TestCubit();
  }

  @override
  void dispose() {
    _testCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocEffectListener<TestCubit, TestEffect>(
          effector: _testCubit,
          listener: (context, effect) {
            widget.onListenerCalled?.call(context, effect);
          },
          child: Column(
            children: [
              ElevatedButton(
                key: const Key('cubit_listener_reset_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _testCubit = TestCubit(value: 2));
                },
              ),
              ElevatedButton(
                key: const Key('cubit_listener_noop_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _testCubit = _testCubit);
                },
              ),
              ElevatedButton(
                key: const Key('cubit_listener_show_snack_bar_button'),
                child: const SizedBox(),
                onPressed: () => _testCubit.showSnackBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('BlocEffectListener', () {
    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('cubit_listener_container');
      final testCubit = TestCubit();
      await tester.pumpWidget(
        BlocEffectListener<TestCubit, TestEffect>(
          effector: testCubit,
          listener: (_, __) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('calls listener on single effect used from TestCubit',
        (tester) async {
      final testCubit = TestCubit();
      final effects = <TestEffect>[];
      const expectedEffects = [ShowSnackBar];
      await tester.pumpWidget(
        BlocEffectListener<TestCubit, TestEffect>(
          effector: testCubit,
          listener: (_, effect) {
            effects.add(effect);
          },
          child: const SizedBox(),
        ),
      );
      testCubit.showSnackBar();
      await tester.pump();
      expect(effects.map((e) => e.runtimeType), expectedEffects);
    });

    testWidgets('calls listener on single effect used from TestBloc',
        (tester) async {
      final testBloc = TestBloc();
      final effects = <TestEffect>[];
      const expectedEffects = [ShowSnackBar];
      await tester.pumpWidget(
        BlocEffectListener<TestBloc, TestEffect>(
          effector: testBloc,
          listener: (_, effect) {
            effects.add(effect);
          },
          child: const SizedBox(),
        ),
      );
      testBloc.add(const ButtonPressed());
      await tester.pump();
      expect(effects.map((e) => e.runtimeType), expectedEffects);
    });

    testWidgets('calls listener on multiple effects used', (tester) async {
      final testCubit = TestCubit();
      final effects = <TestEffect>[];
      const expectedEffects = [ShowSnackBar, ShowSnackBar];
      await tester.pumpWidget(
        BlocEffectListener<TestCubit, TestEffect>(
          effector: testCubit,
          listener: (_, effect) {
            effects.add(effect);
          },
          child: const SizedBox(),
        ),
      );
      testCubit.showSnackBar();
      await tester.pump();
      testCubit.showSnackBar();
      await tester.pump();
      expect(effects.map((e) => e.runtimeType), expectedEffects);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit '
        'and unsubscribes from old cubit', (tester) async {
      var listenerCallCount = 0;
      TestEffect? latestEffect;
      final showSnackBarFinder = find.byKey(
        const Key('cubit_listener_show_snack_bar_button'),
      );
      final resetCubitFinder = find.byKey(
        const Key('cubit_listener_reset_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (_, effect) {
          listenerCallCount++;
          latestEffect = effect;
        },
      ));

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestEffect.runtimeType, ShowSnackBar);

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestEffect.runtimeType, ShowSnackBar);

      await tester.tap(resetCubitFinder);
      await tester.pump();
      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestEffect.runtimeType, ShowSnackBar);
    });

    testWidgets(
        'does not update when the cubit is changed at runtime to same cubit '
        'and stays subscribed to current cubit', (tester) async {
      var listenerCallCount = 0;
      TestEffect? latestEffect;
      final showSnackBarFinder = find.byKey(
        const Key('cubit_listener_show_snack_bar_button'),
      );
      final noopCubitFinder = find.byKey(
        const Key('cubit_listener_noop_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (context, effect) {
          listenerCallCount++;
          latestEffect = effect;
        },
      ));

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestEffect.runtimeType, ShowSnackBar);

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestEffect.runtimeType, ShowSnackBar);

      await tester.tap(noopCubitFinder);
      await tester.pump();
      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestEffect.runtimeType, ShowSnackBar);
    });

    testWidgets('calls listener with correct state', (tester) async {
      final states = <int>[];
      final effects = <TestEffect>[];
      final testCubit = TestCubit();
      await tester.pumpWidget(
        BlocEffectListener<TestCubit, TestEffect>(
          effector: testCubit,
          listener: (_, effect) {
            effects.add(effect);
            if (effect is ShowSnackBar) {
              states.add(effect.stateValue);
            }
          },
          child: const SizedBox(),
        ),
      );
      testCubit.increment();
      await tester.pump();

      testCubit.showSnackBar();
      await tester.pump();

      testCubit.increment();
      await tester.pump();

      testCubit.showSnackBar();
      await tester.pump();

      testCubit.increment();
      await tester.pump();

      testCubit.showSnackBar();
      await tester.pump();

      expect(states, [1, 2, 3]);
      expect(
        effects.map((e) => e.runtimeType),
        [
          ShowSnackBar,
          ShowSnackBar,
          ShowSnackBar,
        ],
      );
    });

    testWidgets(
        'infers the cubit from the context if the cubit is not provided',
        (tester) async {
      TestEffect? latestEffect;
      var listenCallCount = 0;
      final effects = <TestEffect>[];
      final testCubit = TestCubit();
      const expectedEffects = [ShowSnackBar];
      await tester.pumpWidget(
        BlocProvider.value(
          value: testCubit,
          child: BlocEffectListener<TestCubit, TestEffect>(
            listener: (context, effect) {
              listenCallCount++;
              latestEffect = effect;
              effects.add(effect);
            },
            child: const SizedBox(),
          ),
        ),
      );
      testCubit.showSnackBar();
      await tester.pump();

      expect(effects.map((e) => e.runtimeType), expectedEffects);
      expect(listenCallCount, 1);
      expect(latestEffect.runtimeType, ShowSnackBar);
    });

    testWidgets(
        'updates subscription '
        'when provided bloc is changed', (tester) async {
      final firstTestCubit = TestCubit(value: 1);
      final secondTestCubit = TestCubit(value: 100);

      final states = <int>[];
      const expectedStates = [1, 100];

      await tester.pumpWidget(
        BlocProvider.value(
          value: firstTestCubit,
          child: BlocEffectListener<TestCubit, TestEffect>(
            effector: firstTestCubit,
            listener: (_, effect) {
              if (effect is ShowSnackBar) {
                states.add(effect.stateValue);
              }
            },
            child: const SizedBox(),
          ),
        ),
      );

      firstTestCubit.showSnackBar();

      await tester.pumpWidget(
        BlocProvider.value(
          value: secondTestCubit,
          child: BlocEffectListener<TestCubit, TestEffect>(
            effector: secondTestCubit,
            listener: (_, effect) {
              if (effect is ShowSnackBar) {
                states.add(effect.stateValue);
              }
            },
            child: const SizedBox(),
          ),
        ),
      );

      secondTestCubit.showSnackBar();
      await tester.pump();
      firstTestCubit.showSnackBar();
      await tester.pump();

      expect(states, expectedStates);
    });
  });
}
