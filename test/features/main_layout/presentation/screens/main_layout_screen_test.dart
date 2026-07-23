import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/presentation/screens/home_screen.dart';
import 'package:super_fitness/features/main_layout/presentation/screens/main_layout_screen.dart';
import 'package:super_fitness/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:super_fitness/features/profile/presentation/screens/profile_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MaterialApp(home: MainLayoutScreen());
      },
    );
  }

  group('MainLayoutScreen Widget Tests', () {
    testWidgets(
      'Initial State: Should render Custom Navigation Items and initial HomeScreen',
      (WidgetTester tester) async {
        // Set larger surface size to avoid overflow in test environment
        tester.view.physicalSize = const Size(1125, 2436); // 375 * 3, 812 * 3
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify Home tab is selected by checking Key
        expect(find.byKey(const Key('home_tab')), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      },
    );

    testWidgets('Interaction: Tapping on Workout tab should update UI', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Workouts item using its Key
      await tester.tap(find.byKey(const Key('workouts_tab')));
      await tester.pumpAndSettle();

      // Verify that the WorkoutsScreen is now visible
      expect(find.byType(WorkoutsScreen), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Interaction: Tapping on Profile tab should update UI', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Profile item using its Key
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();

      // Verify that the ProfileScreen is now visible
      expect(find.byType(ProfileScreen), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
