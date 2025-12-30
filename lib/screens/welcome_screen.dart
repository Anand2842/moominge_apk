import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moomingle/screens/how_it_works_screen.dart';
import 'package:moomingle/screens/sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?q=80&w=1000&auto=format&fit=crop',
      'title': 'Welcome to the\nFuture of Livestock',
      'subtitle': 'Connecting cattle, empowering farmers.\nExperience smart livestock trading with\na community touch.',
      'tag': 'Herd Status: Healthy',
    },
    {
      'image': 'https://images.unsplash.com/photo-1527153857715-3908f2bae5e8?q=80&w=1000&auto=format&fit=crop',
      'title': 'Swipe to Find\nYour Perfect Match',
      'subtitle': 'Browse through verified cattle listings.\nSwipe right to like, left to pass.\nJust like dating, but for livestock!',
      'tag': 'AI-Powered Matching',
    },
    {
      'image': 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?q=80&w=1000&auto=format&fit=crop',
      'title': 'AI Breed\nIdentification',
      'subtitle': 'Snap a photo and let our AI identify\nthe breed instantly. Supports 10+\nIndian cattle and buffalo breeds.',
      'tag': 'Smart Technology',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HowItWorksScreen()));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 48, color: Color(0xFF5D3A1A)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MooMingle',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5D3A1A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            
            // Swipeable Pages
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < -200) {
                    _nextPage();
                  } else if (details.primaryVelocity! > 200 && _currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    HapticFeedback.lightImpact();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _buildPage(page);
                  },
                ),
              ),
            ),
            
            // Pagination Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
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
            ),

            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ', style: TextStyle(color: Color(0xFF5D3A1A))),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                  child: const Text('Log In', style: TextStyle(color: Color(0xFF5D3A1A), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
          const SizedBox(height: 30),
          // Hero Image (Circular)
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: NetworkImage(page['image']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              // Floating Tag
              Positioned(
                bottom: 30,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAE2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ]
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 10),
                      const SizedBox(width: 6),
                      Text(
                        page['tag'],
                        style: const TextStyle(color: Color(0xFF5D3A1A), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),

          // Welcome Text
          Text(
            page['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page['subtitle'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8B5A2B),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
