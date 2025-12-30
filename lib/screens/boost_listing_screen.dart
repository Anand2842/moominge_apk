import 'package:flutter/material.dart';
import 'package:moomingle/config/app_config.dart';

class BoostListingScreen extends StatefulWidget {
  final String? listingId;
  
  const BoostListingScreen({super.key, this.listingId});

  @override
  State<BoostListingScreen> createState() => _BoostListingScreenState();
}

class _BoostListingScreenState extends State<BoostListingScreen> {
  bool _isLoading = false;

  Future<void> _activateBoost() async {
    // Check if payments are enabled
    if (!AppConfig.enablePayments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Boost feature requires payment integration (coming soon)'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Simulate a brief delay for UX
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚀 Boost activated! Your listing will appear higher in search results for 7 days.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.close, color: Color(0xFF5D3A1A)),
          ),
        ),
        title: const Text('Boost Your Listing', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Rocket Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD3A15F), Color(0xFF8B5A2B)],
                ).createShader(bounds),
                child: const Icon(Icons.rocket_launch, size: 60, color: Colors.white),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text('Supercharge Your Sales', 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
            ),
            const SizedBox(height: 8),
            const Text.rich(
              TextSpan(
                text: 'Get seen by ',
                children: [
                  TextSpan(text: '10x more buyers', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' today.'),
                ],
              ),
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 16),
            
            // Free Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('FREE for all users!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Benefits
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('INCLUDED BENEFITS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            _buildBenefitCard(Icons.bolt, 'Priority in Swipe Deck', 'Appear first in buyers\' feed instantly'),
            const SizedBox(height: 10),
            _buildBenefitCard(Icons.star, 'Highlight Listing', 'Stand out with a Premium Gold border'),
            const SizedBox(height: 10),
            _buildBenefitCard(Icons.verified, 'Verified Seller Badge', 'Build trust instantly with buyers'),
            const SizedBox(height: 10),
            _buildBenefitCard(Icons.insights, 'AI Price Recommendation', 'Get the best market value estimates'),
            const SizedBox(height: 10),
            _buildBenefitCard(Icons.refresh, 'Automatic Reposting', 'Keep your listing fresh every week'),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF5E0C3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _activateBoost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch, size: 20),
                          SizedBox(width: 8),
                          Text('Activate Boost • FREE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Boost lasts for 7 days. You can boost again anytime!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFD3A15F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
