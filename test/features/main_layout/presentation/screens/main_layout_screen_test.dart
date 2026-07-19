import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/presentation/screens/home_screen.dart';
import 'package:super_fitness/features/main_layout/presentation/screens/main_layout_screen.dart';

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
      'Initial State: Should render NavigationBar and initial HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify NavigationBar exists
        expect(find.byType(NavigationBar), findsOneWidget);

        // Verify destinations using find.descendant to avoid duplicate text issues (e.g. text in appbar)
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(AppStrings.explore),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(AppStrings.chat),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(AppStrings.workouts),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(AppStrings.profile),
          ),
          findsOneWidget,
        );

        // Verify HomeScreen is visible
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets('Interaction: Tapping on Workout tab should update UI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Workouts destination within the NavigationBar
      final workoutsDestination = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(AppStrings.workouts),
      );
      await tester.tap(workoutsDestination);
      await tester.pumpAndSettle();

      // Verify that the NavigationBar selected index updated
      final NavigationBar navBar = tester.widget(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2);
    });

    testWidgets('Interaction: Tapping on Profile tab should update UI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Profile destination within the NavigationBar
      final profileDestination = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(AppStrings.profile),
      );
      await tester.tap(profileDestination);
      await tester.pumpAndSettle();

      final NavigationBar navBar = tester.widget(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 3);
    });
  });
}
