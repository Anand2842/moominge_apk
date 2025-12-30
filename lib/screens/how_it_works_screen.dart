import 'package:flutter/material.dart';
import 'package:moomingle/screens/sign_in_screen.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Swipe Right',
      'subtitle': 'See a profile that catches your eye?\nSimply swipe right to show interest.',
      'icon': Icons.thumb_up,
      'iconColor': Colors.green,
    },
    {
      'title': 'It\'s a Match!',
      'subtitle': 'When a seller likes you back,\nyou can start chatting instantly.',
      'icon': Icons.favorite,
      'iconColor': Colors.red,
    },
    {
      'title': 'Chat & Deal',
      'subtitle': 'Negotiate prices, schedule visits,\nand close the deal securely.',
      'icon': Icons.chat_bubble,
      'iconColor': const Color(0xFFD3A15F),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
            child: const Text('Skip', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'How MooMingle Works',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find your herd in 3 simple steps',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8B5A2B), fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            // Swipeable PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 40 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3E2723) : const Color(0xFFD7C7B2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC69C6D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Got it, let\'s go!',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Card Mockup
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF6EE),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner "Phone" mockup
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1DCA7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.brown[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.pets, color: Colors.brown, size: 25),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, size: 10, color: Colors.grey[400]),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 10, color: Colors.grey[800]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating Icon
                Positioned(
                  right: 40,
                  top: 40,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(page['icon'], color: page['iconColor'], size: 30),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            page['title'],
            style: const TextStyle(color: Color(0xFF3E2723), fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            page['subtitle'],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8B5A2B), height: 1.5),
          ),
        ],
      ),
    );
  }
}
