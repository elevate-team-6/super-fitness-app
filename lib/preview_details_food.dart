// TEMPORARY preview entrypoint — boots straight into the meal details screen
// so the layout can be checked without logging in. Delete before committing.
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/di/di.dart';
import 'core/utils/app_constants.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale(AppConstants.englishCode),
        Locale(AppConstants.arabicCode),
      ],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      child: const _PreviewApp(),
    ),
  );
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.mainTheme,
        navigatorKey: AppRoutes.navigatorKey,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.detailsFood,
        // Baked salmon with fennel & tomatoes — the record shared on the ticket.
        onGenerateInitialRoutes: (_) => [
          AppRoutes.onGenerateRoute(
            RouteSettings(
              name: AppRoutes.detailsFood,
              arguments: DetailsFoodArgs(
                mealId: '52959',
                mealName: 'Baked salmon with fennel & tomatoes',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
