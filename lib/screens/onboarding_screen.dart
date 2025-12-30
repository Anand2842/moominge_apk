import 'package:flutter/material.dart';
import 'package:moomingle/screens/tutorial_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // Background Image matching the Highlander cow
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 200),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1541604193435-22287d32c212?q=80&w=1000&auto=format&fit=crop', // Highlander Cow
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // "Moomingle" Brand at top
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child:  Center(
                child: Text(
                  'MOOMINGLE',
                  style: TextStyle(
                    color: Color(0xFF5D3A1A),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Top Breeder Tag
            Positioned(
              top: 130,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAE2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Color(0xFF5D3A1A)),
                    SizedBox(width: 4),
                    Text(
                      'TOP BREEDER',
                      style: TextStyle(
                        color: Color(0xFF5D3A1A),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with Text and Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 50),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Text(
                       'Swipe Right on\nQuality Livestock',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         color: Color(0xFF5D3A1A),
                         fontSize: 36,
                         fontWeight: FontWeight.w900,
                         height: 1.1,
                       ),
                     ),
                     const SizedBox(height: 16),
                     const Text(
                       'The modern way to buy, sell, and\ntrade cattle. Connect with breeders\ninstantly.',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         color: Color(0xFF8B5A2B),
                         fontSize: 16,
                         height: 1.5,
                       ),
                     ),
                     const SizedBox(height: 30),
                     
                     // Pagination Dots
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Container(width: 40, height: 8, decoration: BoxDecoration(color: const Color(0xFF5D3A1A), borderRadius: BorderRadius.circular(4))),
                         const SizedBox(width: 8),
                         Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFD7C7B2), shape: BoxShape.circle)),
                         const SizedBox(width: 8),
                         Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFD7C7B2), shape: BoxShape.circle)),
                       ],
                     ),
                     const SizedBox(height: 30),

                     // Get Started Button
                     SizedBox(
                       width: double.infinity,
                       height: 60,
                       child: ElevatedButton(
                         onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialScreen()));
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF7A5436), // Dark brown
                           foregroundColor: Colors.white,
                           elevation: 0,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(30),
                           ),
                         ),
                         child: const Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(
                               'Get Started',
                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                             ),
                             SizedBox(width: 8),
                             Icon(Icons.arrow_forward),
                           ],
                         ),
                       ),
                     ),
                   ],
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
