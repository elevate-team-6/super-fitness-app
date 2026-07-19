import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/features/auth/domain/utils/social_password_generator.dart';

void main() {
  group('SocialPasswordGenerator', () {
    const tEmail = 'test@example.com';

    test('should return deterministic password for the same email', () {
      final pass1 = SocialPasswordGenerator.deriveFromEmail(tEmail);
      final pass2 = SocialPasswordGenerator.deriveFromEmail(tEmail);

      expect(pass1, equals(pass2));
    });

    test('should return different passwords for different emails', () {
      final pass1 = SocialPasswordGenerator.deriveFromEmail('one@test.com');
      final pass2 = SocialPasswordGenerator.deriveFromEmail('two@test.com');

      expect(pass1, isNot(equals(pass2)));
    });

    test('should satisfy complexity requirements', () {
      final password = SocialPasswordGenerator.deriveFromEmail(tEmail);

      // Length should be 20 as per implementation
      expect(password.length, equals(20));

      // Contains '@'
      expect(password, contains('@'));

      // Contains digits
      expect(password, contains(RegExp(r'\d')));

      // Contains uppercase
      expect(password, contains(RegExp(r'[A-Z]')));

      // Contains lowercase
      expect(password, contains(RegExp(r'[a-z]')));
    });

    test('should handle emails with whitespace and different casing', () {
      final pass1 = SocialPasswordGenerator.deriveFromEmail(' TEST@example.com ');
      final pass2 = SocialPasswordGenerator.deriveFromEmail('test@example.com');

      expect(pass1, equals(pass2));
    });
  });
}
