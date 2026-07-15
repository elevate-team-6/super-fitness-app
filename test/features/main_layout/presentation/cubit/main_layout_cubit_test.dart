import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/features/main_layout/presentation/cubit/main_layout_cubit.dart';

void main() {
  group('MainLayoutCubit', () {
    late MainLayoutCubit mainLayoutCubit;

    setUp(() {
      mainLayoutCubit = MainLayoutCubit();
    });

    tearDown(() {
      mainLayoutCubit.close();
    });

    test('initial state is MainLayoutState(currentIndex: 0)', () {
      expect(mainLayoutCubit.state, const MainLayoutState(currentIndex: 0));
    });

    blocTest<MainLayoutCubit, MainLayoutState>(
      'emits new state with updated index when changeTab is called',
      build: () => mainLayoutCubit,
      act: (cubit) => cubit.changeTab(1),
      expect: () => [const MainLayoutState(currentIndex: 1)],
    );

    blocTest<MainLayoutCubit, MainLayoutState>(
      'emits new state even if same index is called (standard behavior unless optimized)',
      build: () => mainLayoutCubit,
      act: (cubit) => cubit.changeTab(0),
      expect: () => [const MainLayoutState(currentIndex: 0)],
    );
  });
}
