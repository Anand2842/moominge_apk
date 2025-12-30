/// Application configuration management
/// Centralizes all hardcoded values and provides environment-based configuration
class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment type
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://igivbuexkliagpyakngf.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlnaXZidWV4a2xpYWdweWFrbmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2NDcxNTUsImV4cCI6MjA4MjIyMzE1NX0.hSubCrbjs5vxXBaA-gEKdcd2m2u5hKT0waQX4BIvEfg',
  );

  static const String breedApiUrl = String.fromEnvironment(
    'BREED_API_URL',
    defaultValue: 'https://cattle-breed-api-a4q0.onrender.com',
  );

  static const String muzzleApiUrl = String.fromEnvironment(
    'MUZZLE_API_URL',
    defaultValue: 'https://cattle-breed-api-a4q0.onrender.com',
  );

  // App Information
  static const String appVersion = '1.0.2';
  static const String appName = 'Moomingle';
  
  // Contact Information
  static const String supportEmail = 'stufi339@gmail.com';
  static const String supportPhone = '+91-1800-123-4567';
  static const String supportHours = '9 AM - 6 PM IST';
  static const String supportHoursDetail = 'Monday to Saturday, 9 AM - 6 PM IST';
  
  // Feature Flags
  static const bool enableMockData = bool.fromEnvironment(
    'ENABLE_MOCK_DATA',
    defaultValue: false, // Disabled by default for production
  );

  static const bool enablePayments = bool.fromEnvironment(
    'ENABLE_PAYMENTS',
    defaultValue: false,
  );

  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH_NOTIFICATIONS',
    defaultValue: false,
  );

  static const bool enableRealtimeChat = bool.fromEnvironment(
    'ENABLE_REALTIME_CHAT',
    defaultValue: false,
  );

  // Asset URLs
  static const String placeholderImageUrl = 
      'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=800';
  
  static const String defaultAvatarUrl = 
      'https://randomuser.me/api/portraits/men/1.jpg';

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // Validation
  static bool get hasValidSupabaseConfig => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  
  static bool get isConfigured => hasValidSupabaseConfig;
}
