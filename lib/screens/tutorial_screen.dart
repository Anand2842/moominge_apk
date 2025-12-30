import 'package:flutter/material.dart';
import 'package:moomingle/screens/main_wrapper.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D3A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TUTORIAL',
          style: TextStyle(
            color: Color(0xFF8B5A2B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
             const SizedBox(height: 20),
             const Text(
              'Master the Moves',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5D3A1A),
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Swipe your way to the perfect trade.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8B5A2B),
                fontSize: 16,
              ),
            ),
             const SizedBox(height: 40),

            // Tutorial Card Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fake cards behind
                  Transform.translate(
                    offset: const Offset(0, 20),
                    child: Transform.scale(
                      scale: 0.9,
                      child: Container(
                        width: 300,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),

                  // Main Card
                  Container(
                    width: 320,
                    height: 420,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?q=80&w=1000&auto=format&fit=crop', // Bessie mock
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Overlay Gradient
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 200,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                          ),
                        ),
                        // Text Content
                        const Positioned(
                          bottom: 30,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹85,000', 
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                                  ),
                                  // const Icon(Icons.info_outline, color: Colors.white70),
                                ],
                              ),
                               Text(
                                'Bessie, 4 yrs',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Holstein Heifer  •  High Yield',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  Spacer(),
                                  Icon(Icons.info_outline, color: Colors.white, size: 24),
                                ],
                              ),
                             
                            ],
                          ),
                        ),
                        
                        // Fake swipe indicators
                       const Positioned(
                         left: 10,
                         top: 0,
                         bottom: 0,
                         child: Center(child: Icon(Icons.chevron_left, color: Colors.white54, size: 40)),
                       ),
                       const Positioned(
                         right: 10,
                         top: 0,
                         bottom: 0,
                         child: Center(child: Icon(Icons.chevron_right, color: Colors.white54, size: 40)),
                       ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // "Swipe for Details" Indicator
            const Icon(Icons.keyboard_arrow_up, color: Color(0xFF8B5A2B)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('SWIPE FOR DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
            ),
            
            const SizedBox(height: 30),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 _buildActionButton(Icons.close, Colors.white, Colors.red[300]!, 60),
                 const SizedBox(width: 20),
                 _buildActionButton(Icons.star, Colors.white, Colors.orange[300]!, 50),
                 const SizedBox(width: 20),
                 _buildActionButton(Icons.favorite, const Color(0xFFC69C6D), Colors.white, 60),
              ],
            ),

            const SizedBox(height: 30),

            // Start Trading Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                   onPressed: () {
                     // Navigate to Main App and clear stack so back button doesn't return to tutorial
                     Navigator.pushAndRemoveUntil(
                       context,
                       MaterialPageRoute(builder: (context) => const MainWrapper()),
                       (route) => false,
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFFB08958), // Gold/Brown
                     foregroundColor: const Color(0xFF3E2723),
                     elevation: 0,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(30),
                     ),
                   ),
                   child: const Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                         'Start Trading',
                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                       ),
                       SizedBox(width: 8),
                       Icon(Icons.arrow_forward),
                     ],
                   ),
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bgColor, Color iconColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
      ),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
