import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';
import 'package:super_fitness/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:super_fitness/features/workouts/presentation/view_model/workouts_view_model/workouts_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_model/workouts_view_model/workouts_events.dart';
import 'package:super_fitness/features/workouts/presentation/view_model/workouts_view_model/workouts_state.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/muscle_grid_item.dart';
import 'package:super_fitness/core/widgets/custom_loading.dart';

import 'workouts_screen_test.mocks.dart';

// محاكي للترجمة لتجنب مشاكل التحميل من الملفات
class _InMemoryAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => {
        'workouts': 'Workouts',
        'noMusclesFound': 'No muscles found',
        'selectMuscleGroup': 'Select Muscle Group',
      };
}

@GenerateMocks([WorkoutsCubit])
void main() {
  late MockWorkoutsCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;
  late StreamController<WorkoutsState> stateController;

  const surfaceSize = Size(375, 812);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockCubit = MockWorkoutsCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();
    stateController = StreamController<WorkoutsState>.broadcast();

    when(mockCubit.state).thenReturn(const WorkoutsState());
    when(mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    eventController.close();
    stateController.close();
  });

  Future<void> pumpWorkoutsScreen(WidgetTester tester) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: _InMemoryAssetLoader(),
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: surfaceSize,
            builder: (context, child) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: BlocProvider<WorkoutsCubit>.value(
                value: mockCubit,
                child: const WorkoutsScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    // نستخدم pump بدلاً من pumpAndSettle لتجنب التعليق بسبب أنيميشن الـ Lottie
    await tester.pump();
  }

  const tMuscleGroup = MuscleGroupEntity(id: '1', name: 'Abs');
  const tMuscleGroups = [tMuscleGroup];
  const tMuscle = MuscleEntity(id: 'm1', name: 'Crunch', image: 'img.png');
  const tMuscles = [tMuscle];

  group('WorkoutsScreen Rendering Tests', () {
    testWidgets('should display loading when muscleGroupsState is loading', (tester) async {
      when(mockCubit.state).thenReturn(
        const WorkoutsState(muscleGroupsState: BaseState(isLoading: true)),
      );

      await pumpWorkoutsScreen(tester);
      // استخدام pump إضافي لضمان معالجة الـ Stream الأولية
      await tester.pump();
      
      expect(find.byType(CustomLoading), findsWidgets);
    });

    testWidgets('should display muscle groups and muscles when data is loaded', (tester) async {
      when(mockCubit.state).thenReturn(
        const WorkoutsState(
          muscleGroupsState: BaseState(data: tMuscleGroups),
          musclesState: BaseState(data: tMuscles),
          selectedMuscleGroupId: '1',
        ),
      );

      await pumpWorkoutsScreen(tester);
      await tester.pump();

      expect(find.text('Abs'), findsOneWidget);
      expect(find.byType(MuscleGridItem), findsOneWidget);
      expect(find.text('Crunch'), findsOneWidget);
    });

    testWidgets('should display error message when musclesState has error', (tester) async {
      when(mockCubit.state).thenReturn(
        const WorkoutsState(
          muscleGroupsState: BaseState(data: tMuscleGroups),
          musclesState: BaseState(errorMessage: 'Error message'),
          selectedMuscleGroupId: '1',
        ),
      );

      await pumpWorkoutsScreen(tester);
      await tester.pump();
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('should display empty message when no muscles found', (tester) async {
      when(mockCubit.state).thenReturn(
        const WorkoutsState(
          muscleGroupsState: BaseState(data: tMuscleGroups),
          musclesState: BaseState(data: []),
          selectedMuscleGroupId: '1',
        ),
      );

      await pumpWorkoutsScreen(tester);
      await tester.pump();
      expect(find.text('No muscles found'), findsOneWidget);
    });

    testWidgets('should call GetMusclesByGroupIdEvent when a muscle group is tapped', (tester) async {
      when(mockCubit.state).thenReturn(
        const WorkoutsState(
          muscleGroupsState: BaseState(data: tMuscleGroups),
          selectedMuscleGroupId: '1',
        ),
      );

      await pumpWorkoutsScreen(tester);
      await tester.pump();

      await tester.tap(find.text('Abs'));
      await tester.pump();
      
      verify(mockCubit.doEvent(argThat(isA<GetMusclesByGroupIdEvent>()))).called(1);
    });
  });
}
