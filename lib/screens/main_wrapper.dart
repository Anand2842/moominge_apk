import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/seller_hub_screen.dart';
import 'package:moomingle/screens/home_screen.dart';
import 'package:moomingle/screens/chats_screen.dart';
import 'package:moomingle/screens/profile_screen.dart';
import 'package:moomingle/screens/add_cattle_screen.dart';
import 'package:moomingle/services/auth_service.dart';

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  
  const MainWrapper({super.key, this.initialIndex = 0});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isBuyerOnly = authService.isBuyerOnly;
    final canSell = authService.canSell;
    
    // Screens based on user role
    final List<Widget> screens = isBuyerOnly
        ? [
            const HomeScreen(),      // Swipe (index 0)
            const ChatsScreen(),     // Chat (index 1)
            const ProfileScreen(),   // Profile (index 2)
          ]
        : [
            const SellerHubScreen(), // Hub (index 0)
            const HomeScreen(),      // Swipe (index 1)
            const ChatsScreen(),     // Chat (index 2)
            const ProfileScreen(),   // Profile (index 3)
          ];
    
    // Ensure current index is valid
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // Only show FAB for sellers
      floatingActionButton: canSell ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen()));
        },
        backgroundColor: const Color(0xFFD3A15F),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: const BorderRadius.only(
             topLeft: Radius.circular(30),
             topRight: Radius.circular(30),
           ),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, -5),
             )
           ]
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
             topLeft: Radius.circular(30),
             topRight: Radius.circular(30),
           ),
          child: BottomAppBar(
            shape: canSell ? const CircularNotchedRectangle() : null,
            notchMargin: 8,
            color: Colors.white,
            child: SizedBox(
              height: 60,
              child: isBuyerOnly
                  ? _buildBuyerNavBar()
                  : _buildFullNavBar(canSell),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Navigation bar for buyer-only users (no Hub, no FAB)
  Widget _buildBuyerNavBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.style_outlined, Icons.style, 'Browse', 0),
        _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 1),
        _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 2),
      ],
    );
  }
  
  /// Full navigation bar for sellers/both
  Widget _buildFullNavBar(bool canSell) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home_outlined, Icons.home, 'Hub', 0),
        _buildNavItem(Icons.style_outlined, Icons.style, 'Swipe', 1),
        if (canSell) const SizedBox(width: 48), // Space for FAB
        _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 2),
        _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, color: isActive ? const Color(0xFF5D3A1A) : Colors.grey),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF5D3A1A) : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
