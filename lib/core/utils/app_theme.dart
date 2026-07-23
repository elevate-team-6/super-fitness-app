import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData get mainTheme {
    return ThemeData(
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
      canvasColor: AppColors.white,

      // app bar  theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.white20500,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),

      // elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.black10,
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, 38.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
          textStyle: AppTextStyles.white16500,
        ),
      ),

      // outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          minimumSize: Size(double.infinity, 38.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1),
          textStyle: AppTextStyles.white16500,
        ),
      ),

      // text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.primary13500.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // text field
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        hintStyle: AppTextStyles.white2016500,
        labelStyle: AppTextStyles.white13500,
        errorStyle: TextStyle(color: AppColors.red, fontSize: 12.sp),
        errorMaxLines: 4,
        prefixIconColor: AppColors.white,
        suffixIconColor: AppColors.white,
        border: _border(AppColors.white20),
        enabledBorder: _border(AppColors.white20),
        focusedBorder: _border(AppColors.white, 1.5),
        errorBorder: _border(AppColors.red),
        focusedErrorBorder: _border(AppColors.red, 2),
      ),

      // bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.black90,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.white,
        selectedLabelStyle: AppTextStyles.primary13500,
        unselectedLabelStyle: AppTextStyles.white13500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),

      // Navigation Bar Theme (Simplified as we use a custom one)
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // card theme
      cardTheme: CardThemeData(
        color: AppColors.white10,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.r),
          side: const BorderSide(color: AppColors.white20, width: 1),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.black20;
        }),
      ),

      // checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        refreshBackgroundColor: AppColors.white,
      ),

      // switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.white;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.black10;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.white,
        labelStyle: AppTextStyles.white13500,
        unselectedLabelStyle: AppTextStyles.white13500,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        tabAlignment: TabAlignment.start,
      ),

      // dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.black90,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titleTextStyle: AppTextStyles.white16500,
        contentTextStyle: AppTextStyles.white16500,
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.black90,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _border(Color color, [double width = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(100.r),
      borderSide: BorderSide(color: color, width: width),
    );
