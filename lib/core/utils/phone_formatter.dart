/// Converts driver phone numbers between the Egyptian local format used in
/// the UI (`01030313971`) and the international format the backend stores
/// and returns (`+201030313971`).
abstract class PhoneFormatter {
  PhoneFormatter._();

  static const String _countryCode = '+20';

  /// Backend (`+201030313971` / `0020...`) → local (`01030313971`)
  /// so it matches the field and the Egyptian phone validator.
  static String toLocal(String? phone) {
    if (phone == null) return '';
    final value = phone.trim();
    if (value.isEmpty) return '';

    if (value.startsWith(_countryCode)) {
      return '0${value.substring(_countryCode.length)}';
    }
    if (value.startsWith('0020')) {
      return '0${value.substring(4)}';
    }
    return value;
  }

  /// Local (`01030313971`) → international (`+201030313971`) for the
  /// edit-profile request body.
  static String toInternational(String? phone) {
    if (phone == null) return '';
    final value = phone.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('+')) return value;
    if (value.startsWith('0020')) return '$_countryCode${value.substring(4)}';
    if (value.startsWith('0')) return '$_countryCode${value.substring(1)}';
    return '$_countryCode$value';
  }
}
