import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

abstract class DemoEffect {}

class ShowBottomSheet implements DemoEffect {
  const ShowBottomSheet();
}

class DemoCubit extends CubitWithEffects<void, DemoEffect> {
  DemoCubit() : super(null);

  void onButtonPressed() => emitEffect(const ShowBottomSheet());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
        body: BlocEffectListener<DemoCubit, DemoEffect, void>(
          effector: _demoCubit,
          listener: (context, effect, state) {
            if (effect is ShowBottomSheet) {
              showBottomSheet<void>(
                context: context,
                builder: (c) => Material(
                  child: Container(
                    color: Colors.black12,
                    height: 150,
                  ),
                ),
              );
            }
          },
          child: Center(
            child: ElevatedButton(
              onPressed: _demoCubit.onButtonPressed,
              child: const Icon(Icons.upload),
            ),
          ),
        ),
      ),
    );
  }
}
