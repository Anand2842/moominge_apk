import 'package:flutter/material.dart';
import 'package:moomingle/screens/main_wrapper.dart';
import 'package:moomingle/screens/breed_scanner_screen.dart';

class VerificationInfoScreen extends StatelessWidget {
  const VerificationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF869D96), // Muted green/teal vertical gradient start
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF869D96), // Muted teal-ish
              Color(0xFFF5E0C3), // Beige bottom
            ],
            stops: [0.4, 0.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(color: Colors.white),
                    Row(
                      children: [
                         Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle)),
                         const SizedBox(width: 8),
                         Container(width: 40, height: 6, decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(3))),
                         const SizedBox(width: 8),
                         Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle)),
                      ],
                    ),
                    const Text('Skip', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Hero
              Center(
                child: Stack(
                   alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        borderRadius: BorderRadius.circular(40),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1546445317-29f4545e9d53?q=80&w=600&auto=format&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Grid Overlay
                    Container(width: 180, height: 180, decoration: BoxDecoration(border: Border.all(color: Colors.yellow.withOpacity(0.5))), child: const Opacity(opacity: 0.3, child: Icon(Icons.grid_4x4, color: Colors.yellow, size: 100))),
                    
                    // Floating Badge
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDAC083), // Gold
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: const Icon(Icons.verified_user, color: Color(0xFF5D3A1A), size: 30),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Verified Cattle Identity',
                style: TextStyle(
                  color: Color(0xFF5D3A1A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
               const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 40),
                 child: Text(
                  'Secure your herd with AI-powered\nmuzzle recognition technology. Build\ntrust instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5D3A1A),
                    fontSize: 14,
                    height: 1.5,
                  ),
                           ),
               ),
              
              const SizedBox(height: 20),

              // Steps visual (Line with icons)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [Icon(Icons.center_focus_weak, color: Colors.white), SizedBox(height: 4), Text('SCAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D3A1A))) ]),
                    Column(children: [Icon(Icons.smart_toy, color: Colors.white), SizedBox(height: 4), Text('ANALYZE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D3A1A))) ]),
                    Column(children: [Icon(Icons.check_circle, color: Color(0xFF3E2723)), SizedBox(height: 4), Text('VERIFIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D3A1A))) ]),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Why get verified cards (Scrollable or fixed list)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const Text('Why get verified?', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    _buildBenefitCard(Icons.security, 'Fraud Protection', 'Eliminate fake listings with unique biometric IDs.'),
                    const SizedBox(height: 10),
                    _buildBenefitCard(Icons.rocket_launch, 'Boost Visibility', 'Verified herds appear at the top of search results.'),
                    const SizedBox(height: 10),
                    _buildBenefitCard(Icons.handshake, 'Buyer Confidence', 'Buyers prefer verified sellers 3x more often.'),
                  ],
                ),
              ),
              
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Scan Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const BreedScannerScreen()));
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scan Now'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3E2723),
                          side: const BorderSide(color: Color(0xFFDAC083)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context, 
                            MaterialPageRoute(builder: (context) => const MainWrapper()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDAC083),
                          foregroundColor: const Color(0xFF3E2723),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified),
                            SizedBox(width: 8),
                            Text('Verify My Herd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFFAEEDD), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF3E2723), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
                 const SizedBox(height: 4),
                 Text(subtitle, style: const TextStyle(color: Color(0xFF8B5A2B), fontSize: 14)),
               ],
            ),
          )
        ],
      ),
    );
  }
}
