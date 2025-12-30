import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moomingle/services/supabase_service.dart';

/// User role enum
enum UserRole { buyer, seller, both }

/// Authentication service using Supabase Auth
class AuthService extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isDemoMode = false;
  UserRole _userRole = UserRole.both; // Default to both

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null || _isDemoMode;
  bool get isDemoMode => _isDemoMode;
  String? get error => _error;
  UserRole get userRole => _userRole;
  
  /// Check if user can sell (is seller or both)
  bool get canSell => _userRole == UserRole.seller || _userRole == UserRole.both;
  
  /// Check if user is buyer only
  bool get isBuyerOnly => _userRole == UserRole.buyer;

  AuthService() {
    _user = SupabaseService.client.auth.currentUser;
    
    // Listen for auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }
  
  /// Set user role
  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }
  
  /// Set user role from string (for role selection screen)
  void setUserRoleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'buyer':
        _userRole = UserRole.buyer;
        break;
      case 'seller':
        _userRole = UserRole.seller;
        break;
      case 'both':
      default:
        _userRole = UserRole.both;
    }
    notifyListeners();
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Format phone with country code
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
      
      await SupabaseService.client.auth.signInWithOtp(
        phone: formattedPhone,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send OTP. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
      
      final response = await SupabaseService.client.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );
      
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = 'Invalid OTP. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email (for demo/testing)
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = 'Invalid credentials';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email (for demo/testing)
  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Anonymous sign in (for demo mode)
  /// Returns false if anonymous auth is disabled, allowing fallback to local demo
  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signInAnonymously();
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      print('⚠️ Anonymous auth failed: $e');
      // Don't set error - let caller handle fallback
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
    _user = null;
    _isDemoMode = false;
    notifyListeners();
  }

  /// Enter local demo mode (no Supabase required)
  Future<bool> enterDemoMode() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate a brief delay for UX
    await Future.delayed(const Duration(milliseconds: 500));

    _isDemoMode = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
