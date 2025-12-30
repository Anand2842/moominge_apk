import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/main_wrapper.dart';
import 'package:moomingle/services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        actions: [
          TextButton(
            onPressed: () => _navigateToHome('both', 1), // Default to both/swipe
            child: const Text('Skip', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
               // Pagination Dots
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD7C7B2), shape: BoxShape.circle)),
                   const SizedBox(width: 8),
                   Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD7C7B2), shape: BoxShape.circle)),
                   const SizedBox(width: 8),
                   Container(width: 40, height: 6, decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(3))),
                 ],
               ),
              const SizedBox(height: 30),
              
              const Text(
                'What brings you to\nthe herd?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We\'ll customize your feed and tools based\non your needs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8B5A2B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Role options
              _buildRoleOption(
                Icons.shopping_cart,
                'I\'m a Buyer',
                'Browse verified cattle near you',
                'buyer',
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                Icons.storefront,
                'I\'m a Seller',
                'List your cattle for buyers',
                'seller',
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                Icons.swap_horiz,
                'Both',
                'Buy and sell livestock',
                'both',
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF5E0C3),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _selectedRole == null ? null : () {
              if (_selectedRole == 'buyer') {
                _navigateToHome('buyer', 1); // Swipe tab (Buyer Home)
              } else if (_selectedRole == 'seller') {
                _navigateToHome('seller', 0); // Hub tab (Seller Dashboard)
              } else {
                _navigateToHome('both', 0); // Default to Hub for "Both"
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC69C6D),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHome(String role, int tabIndex) {
    // Save user role
    context.read<AuthService>().setUserRoleFromString(role);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainWrapper(initialIndex: tabIndex)),
      (route) => false,
    );
  }

  Widget _buildRoleOption(IconData icon, String title, String subtitle, String value) {
    bool isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: const Color(0xFFC69C6D), width: 2) : null,
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFAEEDD),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF5D3A1A), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF3E2723))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF8B5A2B), fontSize: 14)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFC69C6D) : Colors.grey[300]!,
                  width: 2,
                ),
                 color: isSelected ? const Color(0xFFC69C6D) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            )
          ],
        ),
      ),
    );
  }
}
