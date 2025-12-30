import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/screens/privacy_policy_screen.dart';
import 'package:moomingle/screens/terms_of_service_screen.dart';
import 'package:moomingle/screens/create_profile_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    final auth = context.read<AuthService>();
    bool success;

    if (_isSignUp) {
      success = await auth.signUpWithEmail(email, password);
    } else {
      success = await auth.signInWithEmail(email, password);
    }

    if (success && mounted) {
      // Navigate to profile setup for new flow
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
      );
    } else if (mounted && auth.error != null) {
      _showError(auth.error!);
    }
  }

  Future<void> _continueAsGuest() async {
    final auth = context.read<AuthService>();
    
    // Go straight to local demo mode (no Supabase dependency)
    final success = await auth.enterDemoMode();
    
    if (success && mounted) {
      // Navigate to profile setup for new flow
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
      );
    } else if (mounted) {
      _showError('Could not start demo mode');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _isSignUp ? 'Create Account 🐄' : 'Welcome Back 👋',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSignUp
                  ? 'Sign up to start trading cattle'
                  : 'Sign in to continue trading cattle',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 40),

            // Email Input
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'your@email.com',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF9E8A78)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password Input
            const Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E8A78)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF9E8A78),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sign In / Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleEmailAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle Sign In / Sign Up
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text.rich(
                  TextSpan(
                    text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: _isSignUp ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(
                          color: Color(0xFFD3A15F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),

            const SizedBox(height: 24),

            // Demo Mode Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: auth.isLoading ? null : _continueAsGuest,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Try Demo Mode', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3E2723),
                  side: const BorderSide(color: Color(0xFFD7C7B2), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Demo mode hint
            const Center(
              child: Text(
                'No account needed - explore the app instantly',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 40),

            // Terms
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    'By continuing, you agree to our ',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                    ),
                    child: const Text(
                      'Terms',
                      style: TextStyle(
                        color: Color(0xFFD3A15F),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Text(
                    ' and ',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    ),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFFD3A15F),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
