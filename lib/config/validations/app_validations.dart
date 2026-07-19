import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:super_fitness/core/utils/app_strings.dart';

abstract class AppValidations {
  AppValidations._();

  // ── Generic ──
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired.tr(args: [field]);
    }
    return null;
  }

  // Vehicle Number
  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.vehicleNumberRequired.tr();
    }
    return null;
  }

  // National ID
  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.idNumberRequired.tr();
    }

    if (!RegExp(r'^\d{14}$').hasMatch(value.trim())) {
      return AppStrings.invalidIdNumber.tr();
    }

    return null;
  }

  // Dropdown
  static String? validateDropdown<T>(T? value, String fieldName) {
    if (value == null) {
      return '$fieldName ${AppStrings.isRequired.tr()}';
    }

    if (value is String && value.trim().isEmpty) {
      return '$fieldName ${AppStrings.isRequired.tr()}';
    }

    return null;
  }

  // ── Name ──
  static String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.usernameRequired.tr();
    }
    if (value.length < 3) {
      return AppStrings.usernameTooShort.tr();
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return AppStrings.usernameInvalid.tr();
    }
    return null;
  }

  static String? nationalIdImage(File? image) {
    if (image == null) {
      return AppStrings.pleaseUploadNationalId.tr();
    }
    return null;
  }

  static String? drivingLicenseImage({File? image, String? imageUrl}) {
    if (image == null && (imageUrl == null || imageUrl.isEmpty)) {
      return AppStrings.pleaseUploadDrivingLicense.tr();
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.firstNameRequired.tr();
    }
    if (value.trim().length < 3) {
      return AppStrings.nameTooShort.tr();
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return AppStrings.nameNoNumbers.tr();
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.lastNameRequired.tr();
    }
    if (value.trim().length < 3) {
      return AppStrings.nameTooShort.tr();
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return AppStrings.nameNoNumbers.tr();
    }
    return null;
  }

  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.recipientNameRequired.tr();
    }
    if (value.trim().length < 3) {
      return AppStrings.nameTooShort.tr();
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return AppStrings.nameNoNumbers.tr();
    }
    return null;
  }

  // ── Email ──
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired.tr();
    }
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail.tr();
    }
    return null;
  }

  // ── Password ──
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired.tr();
    }

    if (value.length < 8) {
      return AppStrings.passwordTooShort.tr();
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppStrings.passwordLowercase.tr();
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppStrings.passwordUppercase.tr();
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppStrings.passwordNumber.tr();
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppStrings.passwordSpecialCharacter.tr();
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired.tr();
    }
    if (value != password) {
      return AppStrings.passwordNotMatched.tr();
    }
    return null;
  }

  // ── Phone ──
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.phoneRequired.tr();
    }

    final phone = value.trim();

    final regex = RegExp(r'^01[0-2,5]{1}[0-9]{8}$');

    if (!regex.hasMatch(phone)) {
      return AppStrings.phoneRequiredEgyptian.tr();
    }
    return null;
  }
}
