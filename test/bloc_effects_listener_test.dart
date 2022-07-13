import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class DemoEffect {}

class ShowSnackBar implements DemoEffect {
  const ShowSnackBar();
}

class DemoCubit extends CubitWithEffects<int, DemoEffect> {
  DemoCubit({int value = 0}) : super(value);

  void showSnackBar() => useEffect(const ShowSnackBar());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.onListenerCalled}) : super(key: key);

  final EffectWidgetListener<DemoEffect, int>? onListenerCalled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DemoCubit _demoCubit;

  @override
  void initState() {
    super.initState();
    _demoCubit = DemoCubit();
  }

  @override
  void dispose() {
    _demoCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocEffectListener<DemoCubit, DemoEffect, int>(
          effector: _demoCubit,
          listener: (context, effect, state) {
            widget.onListenerCalled?.call(context, effect, state);
          },
          child: Column(
            children: [
              ElevatedButton(
                key: const Key('cubit_listener_reset_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _demoCubit = DemoCubit(value: 2));
                },
              ),
              ElevatedButton(
                key: const Key('cubit_listener_noop_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _demoCubit = _demoCubit);
                },
              ),
              ElevatedButton(
                key: const Key('cubit_listener_show_snack_bar_button'),
                child: const SizedBox(),
                onPressed: () => _demoCubit.showSnackBar(),
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
      final demoCubit = DemoCubit();
      await tester.pumpWidget(
        BlocEffectListener<DemoCubit, DemoEffect, int>(
          effector: demoCubit,
          listener: (_, __, ___) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('calls listener on single effect used', (tester) async {
      final demoCubit = DemoCubit();
      final effects = <DemoEffect>[];
      const expectedEffects = [ShowSnackBar()];
      await tester.pumpWidget(
        BlocEffectListener<DemoCubit, DemoEffect, int>(
          effector: demoCubit,
          listener: (_, effect, __) {
            effects.add(effect);
          },
          child: const SizedBox(),
        ),
      );
      demoCubit.showSnackBar();
      await tester.pump();
      expect(effects, expectedEffects);
    });

    testWidgets('calls listener on multiple effects used', (tester) async {
      final demoCubit = DemoCubit();
      final effects = <DemoEffect>[];
      const expectedEffects = [ShowSnackBar(), ShowSnackBar()];
      await tester.pumpWidget(
        BlocEffectListener<DemoCubit, DemoEffect, int>(
          effector: demoCubit,
          listener: (_, effect, __) {
            effects.add(effect);
          },
          child: const SizedBox(),
        ),
      );
      demoCubit.showSnackBar();
      await tester.pump();
      demoCubit.showSnackBar();
      await tester.pump();
      expect(effects, expectedEffects);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit '
        'and unsubscribes from old cubit', (tester) async {
      var listenerCallCount = 0;
      DemoEffect? latestEffect;
      final showSnackBarFinder = find.byKey(
        const Key('cubit_listener_show_snack_bar_button'),
      );
      final resetCubitFinder = find.byKey(
        const Key('cubit_listener_reset_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (_, effect, __) {
          listenerCallCount++;
          latestEffect = effect;
        },
      ));

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestEffect, const ShowSnackBar());

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestEffect, const ShowSnackBar());

      await tester.tap(resetCubitFinder);
      await tester.pump();
      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestEffect, const ShowSnackBar());
    });

    testWidgets(
        'does not update when the cubit is changed at runtime to same cubit '
        'and stays subscribed to current cubit', (tester) async {
      var listenerCallCount = 0;
      DemoEffect? latestEffect;
      final showSnackBarFinder = find.byKey(
        const Key('cubit_listener_show_snack_bar_button'),
      );
      final noopCubitFinder = find.byKey(
        const Key('cubit_listener_noop_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (context, effect, __) {
          listenerCallCount++;
          latestEffect = effect;
        },
      ));

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestEffect, const ShowSnackBar());

      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestEffect, const ShowSnackBar());

      await tester.tap(noopCubitFinder);
      await tester.pump();
      await tester.tap(showSnackBarFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestEffect, const ShowSnackBar());
    });

    testWidgets(
        'infers the cubit from the context if the cubit is not provided',
        (tester) async {
      DemoEffect? latestEffect;
      var listenCallCount = 0;
      final effects = <DemoEffect>[];
      final demoCubit = DemoCubit();
      const expectedEffects = [ShowSnackBar()];
      await tester.pumpWidget(
        BlocProvider.value(
          value: demoCubit,
          child: BlocEffectListener<DemoCubit, DemoEffect, int>(
            listener: (context, effect, __) {
              listenCallCount++;
              latestEffect = effect;
              effects.add(effect);
            },
            child: const SizedBox(),
          ),
        ),
      );
      demoCubit.showSnackBar();
      await tester.pump();

      expect(effects, expectedEffects);
      expect(listenCallCount, 1);
      expect(latestEffect, const ShowSnackBar());
    });

    testWidgets(
        'updates subscription '
        'when provided bloc is changed', (tester) async {
      final firstDemoCubit = DemoCubit(value: 1);
      final secondDemoCubit = DemoCubit(value: 100);

      final states = <int>[];
      const expectedStates = [1, 100];

      await tester.pumpWidget(
        BlocProvider.value(
          value: firstDemoCubit,
          child: BlocEffectListener<DemoCubit, DemoEffect, int>(
            effector: firstDemoCubit,
            listener: (_, __, state) {
              states.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );

      firstDemoCubit.showSnackBar();

      await tester.pumpWidget(
        BlocProvider.value(
          value: secondDemoCubit,
          child: BlocEffectListener<DemoCubit, DemoEffect, int>(
            effector: secondDemoCubit,
            listener: (_, __, state) {
              states.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );

      secondDemoCubit.showSnackBar();
      await tester.pump();
      firstDemoCubit.showSnackBar();
      await tester.pump();

      expect(states, expectedStates);
    });
  });
}
