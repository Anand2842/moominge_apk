import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/main_wrapper.dart';
import 'package:moomingle/screens/welcome_screen.dart';
import 'package:moomingle/screens/splash_screen.dart';
import 'package:moomingle/services/api_service.dart';
import 'package:moomingle/services/chat_service.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/services/supabase_service.dart';
import 'package:moomingle/services/muzzle_service.dart';
import 'package:moomingle/services/user_profile_service.dart';
import 'package:moomingle/services/seller_stats_service.dart';
import 'package:moomingle/services/settings_service.dart';
import 'package:moomingle/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MoomingleApp());
}

class MoomingleApp extends StatelessWidget {
  const MoomingleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => MuzzleService()),
        ChangeNotifierProvider(create: (_) => UserProfileService()),
        ChangeNotifierProvider(create: (_) => SellerStatsService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => AnalyticsService()),
      ],
      child: MaterialApp(
        title: 'Moomingle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5E0C3),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5A2B),
            primary: const Color(0xFF8B5A2B),
          ),
          fontFamily: 'Roboto',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper that shows appropriate screen based on auth state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const MainWrapper();
        }
        return const WelcomeScreen();
      },
    );
  }
}
