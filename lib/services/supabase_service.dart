import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Supabase configuration and client access
/// 
/// Configuration is managed through AppConfig.
/// For production builds, set environment variables:
/// flutter build apk --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
class SupabaseService {
  static Future<void> initialize() async {
    // Check if configuration is available
    if (!AppConfig.isConfigured) {
      print('⚠️ Supabase not configured. Running in mock mode.');
      print('Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.');
      return;
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static bool get isInitialized => AppConfig.isConfigured;
}
