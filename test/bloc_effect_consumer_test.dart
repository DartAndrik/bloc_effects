import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bloc_effect_listener_test.dart';

abstract class TestEvent {}

class ButtonPressed implements TestEvent {
  const ButtonPressed();
}

class Increment implements TestEvent {
  const Increment();
}

class TestCubit extends CubitWithEffects<int, TestEffect> {
  TestCubit({int value = 0}) : super(value);

  void showSnackBar() => emitEffect(ShowSnackBar(state));
  void increment() => emit(state + 1);
}

class TestBloc extends BlocWithEffects<TestEvent, int, TestEffect> {
  TestBloc({int value = 0}) : super(value) {
    on<ButtonPressed>(_onButtonPressed);
    on<Increment>(_onIncrement);
  }

  void _onButtonPressed(_, __) => emitEffect(ShowSnackBar(state));
  void _onIncrement(_, Emitter<int> emit) => emit(state + 1);
}

class ProviderConsumerHarness extends StatelessWidget {
  const ProviderConsumerHarness({
    required this.cubit,
    required this.effectStates,
    super.key,
  });

  final TestCubit cubit;
  final List<int> effectStates;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TestCubit>.value(
      value: cubit,
      child: BlocEffectConsumer<TestCubit, int, TestEffect>(
        listener: (_, effect) {
          if (effect is ShowSnackBar) effectStates.add(effect.stateValue);
        },
        builder: (_, state) => Directionality(
          textDirection: TextDirection.ltr,
          child: Text('$state'),
        ),
      ),
    );
  }
}

void main() {
  group('BlocEffectConsumer', () {
    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('cubit_listener_container');
      final testCubit = TestCubit();
      await tester.pumpWidget(
        BlocEffectConsumer<TestCubit, int, TestEffect>(
          bloc: testCubit,
          listener: (_, __) {},
          builder: (_, int value) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$value',
              key: targetKey,
            ),
          ),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('calls listener on single effect used from TestCubit',
        (tester) async {
      final testCubit = TestCubit();
      final effects = <TestEffect>[];
      const expectedEffects = [ShowSnackBar];
      await tester.pumpWidget(
        BlocEffectConsumer<TestCubit, int, TestEffect>(
          bloc: testCubit,
          listener: (_, effect) => effects.add(effect),
          builder: (_, int value) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$value',
            ),
          ),
        ),
      );
      testCubit
        ..showSnackBar()
        ..increment();
      await tester.pumpAndSettle();
      expect(effects.map((e) => e.runtimeType), expectedEffects);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('calls listener on single effect used from TestBloc',
        (tester) async {
      final testBloc = TestBloc();
      final effects = <TestEffect>[];
      const expectedEffects = [ShowSnackBar];
      await tester.pumpWidget(
        BlocEffectConsumer<TestBloc, int, TestEffect>(
          bloc: testBloc,
          listener: (_, effect) => effects.add(effect),
          builder: (_, int value) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$value',
            ),
          ),
        ),
      );
      testBloc
        ..add(const ButtonPressed())
        ..add(const Increment());
      await tester.pumpAndSettle();
      expect(effects.map((e) => e.runtimeType), expectedEffects);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('calls listener on multiple effects used', (tester) async {
      final testCubit = TestCubit();
      final effects = <TestEffect>[];
      const expectedEffects = [ShowSnackBar, ShowSnackBar];
      await tester.pumpWidget(
        BlocEffectConsumer<TestCubit, int, TestEffect>(
          bloc: testCubit,
          listener: (_, effect) => effects.add(effect),
          builder: (_, int value) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$value',
            ),
          ),
        ),
      );
      testCubit
        ..showSnackBar()
        ..increment();
      await tester.pumpAndSettle();
      testCubit
        ..showSnackBar()
        ..increment();
      await tester.pumpAndSettle();
      expect(effects.map((e) => e.runtimeType), expectedEffects);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('keeps builder and listener on the same replacement cubit',
        (tester) async {
      final firstCubit = TestCubit(value: 1);
      final secondCubit = TestCubit(value: 100);
      final effectStates = <int>[];
      addTearDown(firstCubit.close);
      addTearDown(secondCubit.close);

      await tester.pumpWidget(
        ProviderConsumerHarness(
          cubit: firstCubit,
          effectStates: effectStates,
        ),
      );
      await tester.pumpWidget(
        ProviderConsumerHarness(
          cubit: secondCubit,
          effectStates: effectStates,
        ),
      );
      expect(find.text('100'), findsOneWidget);

      secondCubit.showSnackBar();
      await tester.pump();
      firstCubit.showSnackBar();
      await tester.pump();

      expect(effectStates, <int>[100]);
    });
  });
}
