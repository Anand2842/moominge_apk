import 'package:flutter/material.dart';
import 'package:moomingle/screens/add_cattle_screen.dart';
import 'package:moomingle/screens/muzzle_capture_screen.dart';
import 'package:moomingle/services/muzzle_service.dart';
import 'package:moomingle/config/app_config.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  bool _muzzleVerified = false;
  String? _muzzleId;

  int get _trustScore {
    int score = 60; // Base score
    if (_muzzleVerified) score += 15;
    // Phone + Profile already complete = +20
    score += 20;
    return score.clamp(0, 100);
  }

  void _submitUpdate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen()));
  }

  Future<void> _startMuzzleVerification() async {
    final result = await Navigator.push<MuzzleVerificationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const MuzzleCaptureScreen(
          listingId: 'herd-verification',
          animalName: 'My Herd',
          isVerification: false,
        ),
      ),
    );

    if (result != null && result.success) {
      setState(() {
        _muzzleVerified = true;
        _muzzleId = result.muzzleId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Verification Status', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(AppConfig.defaultAvatarUrl),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sunny Side Ranch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 14),
                          SizedBox(width: 4),
                          Text('Level 2 Seller', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Verification Steps
            const Text('VERIFICATION STEPS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            
            _buildVerificationStep(
              context,
              icon: Icons.phone,
              title: 'Phone Verification',
              status: 'Completed',
              statusColor: Colors.green,
              subtitle: 'Verified on Oct 12, 2023',
              isComplete: true,
            ),
            const SizedBox(height: 12),
            _buildVerificationStep(
              context,
              icon: Icons.person,
              title: 'Profile Completion',
              status: 'Completed',
              statusColor: Colors.green,
              subtitle: 'Business details approved',
              isComplete: true,
            ),
            const SizedBox(height: 12),
            _buildVerificationStep(
              context,
              icon: Icons.face,
              title: 'Muzzle Biometric',
              status: _muzzleVerified ? 'Completed' : 'Not Started',
              statusColor: _muzzleVerified ? Colors.green : Colors.orange,
              subtitle: _muzzleVerified 
                  ? 'Verified • $_muzzleId'
                  : 'Tap to start muzzle scan',
              isComplete: _muzzleVerified,
              showProgress: false,
              onTap: _muzzleVerified ? null : _startMuzzleVerification,
            ),
            const SizedBox(height: 12),
            _buildVerificationStep(
              context,
              icon: Icons.update,
              title: 'Weekly Update',
              status: 'Needs Update',
              statusColor: Colors.red,
              subtitle: 'Last update: 9 days ago',
              isComplete: false,
              showButton: true,
            ),
            
            const SizedBox(height: 24),
            
            // Trust Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seller Trust Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Based on verification & activity', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '$_trustScore', style: const TextStyle(color: Color(0xFF3E2723), fontSize: 40, fontWeight: FontWeight.w900)),
                            const TextSpan(text: '/100', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _trustScore / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD3A15F)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pro Tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Color(0xFFD3A15F), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _muzzleVerified
                                ? 'Great! Muzzle verification adds trust. Keep your listings updated!'
                                : 'Pro Tip: Complete muzzle verification to boost your score by 15 points.',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF5D3A1A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen())),
        backgroundColor: const Color(0xFFD3A15F),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.style, 'Swipe', false),
              _buildNavItem(Icons.chat_bubble, 'Chat', false),
              const SizedBox(width: 40),
              _buildNavItem(Icons.storefront, 'Orders', false),
              _buildNavItem(Icons.verified_user, 'Verify', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String subtitle,
    required bool isComplete,
    bool showProgress = false,
    bool showButton = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (showButton) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _submitUpdate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2723),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Submit Update', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
            if (isComplete)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else if (showProgress)
              const Icon(Icons.hourglass_bottom, color: Colors.orange, size: 24)
            else if (onTap != null)
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
            else
              const Icon(Icons.error, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF5D3A1A) : Colors.grey, size: 24),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF5D3A1A) : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
