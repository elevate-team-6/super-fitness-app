import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/presentation/screens/exercise_details_screen.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercise_details_hero.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/muscle_targeting_section.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/required_equipment_section.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/technical_specs_grid.dart';

class _InMemoryAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => {
    'exerciseDetails': 'Exercise Details',
    'technicalSpecs': 'Technical Specs',
    'musclesTargeted': 'Muscle Targeting',
    'requiredEquipment': 'Required Equipment',
    'primeMover': 'Prime Mover',
    'secondary': 'Secondary',
  };
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  const tExercise = ExerciseEntity(
    id: 'ex1',
    exercise: 'Bench Press',
    difficultyLevel: 'Intermediate',
    targetMuscleGroup: 'Chest',
    primeMoverMuscle: 'Pectoralis Major',
    primaryEquipment: 'Barbell',
    secondaryEquipment: 'Bench',
    posture: 'Supine',
    grip: 'Wide',
    forceType: 'Push',
    secondaryMuscles: 'Triceps, Front Delts',
    tertiaryMuscles: '',
    bodyRegion: 'Upper Body',
    mechanics: 'Compound',
    laterality: 'Bilateral',
    primaryExerciseClassification: 'Push',
    shortYoutubeDemonstrationLink: 'https://youtube.com/shorts/sample',
    inDepthYoutubeExplanationLink: '',
  );

  const surfaceSize = Size(375, 812);

  Future<void> pumpExerciseDetailsScreen(WidgetTester tester) async {
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
              home: const ExerciseDetailsScreen(exercise: tExercise),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('ExerciseDetailsScreen Widget Tests', () {
    testWidgets('should render all sections correctly', (tester) async {
      await pumpExerciseDetailsScreen(tester);

      // Header info
      expect(find.text('Exercise Details'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Chest • Intermediate'), findsOneWidget);

      // Components
      expect(find.byType(ExerciseDetailsHero), findsOneWidget);
      expect(find.byType(TechnicalSpecsGrid), findsOneWidget);
      expect(find.byType(MuscleTargetingSection), findsOneWidget);
      expect(find.byType(RequiredEquipmentSection), findsOneWidget);
    });

    testWidgets('should display technical specs values', (tester) async {
      await pumpExerciseDetailsScreen(tester);

      expect(find.text('Wide'), findsOneWidget); // Grip
      expect(find.text('Supine'), findsOneWidget); // Posture
      expect(find.text('Compound'), findsOneWidget); // Mechanics
      expect(find.text('Push'), findsOneWidget); // Force Type
    });

    testWidgets('should display muscle targeting information', (tester) async {
      await pumpExerciseDetailsScreen(tester);

      expect(find.text('Pectoralis Major'), findsOneWidget);
      expect(find.text('Triceps'), findsOneWidget);
      expect(find.text('Front Delts'), findsOneWidget);
    });

    testWidgets('should display equipment information', (tester) async {
      await pumpExerciseDetailsScreen(tester);

      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Bench'), findsOneWidget);
    });
  });
}
