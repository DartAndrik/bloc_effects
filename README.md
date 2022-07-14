<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
<p align="center">
<a href="https://pub.dev/packages/bloc_effects"><img src="https://img.shields.io/pub/v/bloc_effects.svg" alt="Pub"></a>
<a href="https://codecov.io/gh/DartAndrik/bloc_effects"><img src="https://codecov.io/gh/DartAndrik/bloc_effects/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/passsy/dart-lint"><img src="https://img.shields.io/badge/style-lint-40c4ff.svg" alt="style: lint"></a>
</p>

The abstractions on Cubit and Bloc and Flutter Widget that make it easy to add UI Effects to the BLoC state
management using [package:bloc](https://pub.dev/packages/bloc).

## Usage

Lets take a look at how to use `CubitWithEffects` to dispatch effects from `CounterCubit` to
a `CounterPage` and react on them with `BlocEffectListener`.

### ui_effect.dart

 ```dart
abstract class UiEffect {}

class ShowBottomSheet implements UiEffect {
  const ShowBottomSheet();
}
 ```

### counter_cubit.dart

 ```dart
 class CounterCubit extends CubitWithEffects<int, UiEffect> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  void onButtonPressed() => useEffect(const ShowBottomSheet());
}
 ```

### main.dart

```dart
void main() => runApp(CounterApp());

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => CounterCubit(),
        child: CounterPage(),
      ),
    );
  }
}
```

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: BlocEffectListener<CounterCubit, SomeEffect, int>(
        listener: (context, effect, state) {
          if (effect is ShowBottomSheet) {
            showBottomSheet<void>(
              context: context,
              builder: (c) =>
                  Material(
                    child: Container(
                      color: Colors.black12,
                      height: 150,
                    ),
                  ),
            );
          }
        },
        child: const Sizedbox(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () => context.read<CounterCubit>().onButtonPressed(),
      ),
    );
  }
}
```
