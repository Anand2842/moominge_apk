import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should initialize with no user', () {
      expect(authService.currentUser, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('should handle sign in', () async {
      await authService.signInWithEmail(
        'test@example.com',
        'password123',
      );
      // Should not throw error in mock mode
    });

    test('should handle sign up', () async {
      await authService.signUpWithEmail(
        'newuser@example.com',
        'password123',
        'Test User',
      );
      // Should not throw error in mock mode
    });

    test('should handle sign out', () async {
      await authService.signOut();
      expect(authService.currentUser, isNull);
    });

    test('should handle password reset', () async {
      await authService.resetPassword('test@example.com');
      // Should not throw error
    });

    test('should handle authentication state', () {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });
  });
}
