import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moomingle/models/cow_listing.dart';
import 'package:moomingle/screens/profile_detail_screen.dart';
import 'package:moomingle/screens/match_screen.dart';
import 'package:moomingle/widgets/safe_image.dart';

class CowCard extends StatefulWidget {
  final CowListing cow;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const CowCard({
    super.key, 
    required this.cow,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  State<CowCard> createState() => _CowCardState();
}

class _CowCardState extends State<CowCard> with TickerProviderStateMixin {
  double _dragX = 0;
  double _dragY = 0;
  bool _isDragging = false;
  Offset _dragStart = Offset.zero;
  
  late AnimationController _springController;
  late AnimationController _swipeOutController;
  late Animation<double> _springAnimation;
  
  // Swipe thresholds
  static const double _swipeThreshold = 100;
  static const double _velocityThreshold = 600;
  
  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _swipeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _springController.dispose();
    _swipeOutController.dispose();
    super.dispose();
  }

  double get _rotation => (_dragX / 400) * 0.4; // Max ~23 degrees rotation
  
  double get _likeOpacity => (_dragX / _swipeThreshold).clamp(0.0, 1.0);
  double get _nopeOpacity => (-_dragX / _swipeThreshold).clamp(0.0, 1.0);
  double get _infoOpacity => (-_dragY / 80).clamp(0.0, 1.0);

  void _onPanStart(DragStartDetails details) {
    _springController.stop();
    _swipeOutController.stop();
    setState(() {
      _isDragging = true;
      _dragStart = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;
    });
    
    // Haptic feedback at threshold
    if (_dragX.abs() > _swipeThreshold && _dragX.abs() < _swipeThreshold + 10) {
      HapticFeedback.lightImpact();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;
    
    setState(() => _isDragging = false);
    
    // Swipe up for details
    if (_dragY < -100 || velocity.dy < -800) {
      _springBack();
      HapticFeedback.mediumImpact();
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileDetailScreen(cow: widget.cow)));
      return;
    }
    
    // Right swipe - Like
    if (_dragX > _swipeThreshold || velocity.dx > _velocityThreshold) {
      _animateSwipeOut(screenWidth * 1.5, _dragY, isLike: true);
      HapticFeedback.heavyImpact();
    } 
    // Left swipe - Pass
    else if (_dragX < -_swipeThreshold || velocity.dx < -_velocityThreshold) {
      _animateSwipeOut(-screenWidth * 1.5, _dragY, isLike: false);
      HapticFeedback.heavyImpact();
    } 
    // Spring back to center
    else {
      _springBack();
    }
  }
  
  void _springBack() {
    final startX = _dragX;
    final startY = _dragY;
    
    _springAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );
    
    _springController.reset();
    _springController.forward();
    
    _springAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _dragX = startX * _springAnimation.value;
          _dragY = startY * _springAnimation.value;
        });
      }
    });
  }

  void _animateSwipeOut(double targetX, double targetY, {required bool isLike}) {
    final startX = _dragX;
    final startY = _dragY;
    
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeOutController, curve: Curves.easeOut),
    );
    
    _swipeOutController.reset();
    
    animation.addListener(() {
      if (mounted) {
        setState(() {
          _dragX = startX + (targetX - startX) * animation.value;
          _dragY = startY + (targetY - startY) * animation.value;
        });
      }
    });
    
    _swipeOutController.forward().then((_) {
      if (isLike) {
        widget.onSwipeRight?.call();
        Navigator.push(context, MaterialPageRoute(builder: (_) => MatchScreen(cow: widget.cow)));
      } else {
        widget.onSwipeLeft?.call();
      }
      // Reset position
      setState(() {
        _dragX = 0;
        _dragY = 0;
      });
    });
  }

  void _onLikePressed() {
    HapticFeedback.heavyImpact();
    _animateSwipeOut(MediaQuery.of(context).size.width * 1.5, 0, isLike: true);
  }

  void _onNopePressed() {
    HapticFeedback.heavyImpact();
    _animateSwipeOut(-MediaQuery.of(context).size.width * 1.5, 0, isLike: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_dragX, _dragY)
          ..rotateZ(_rotation),
        child: Stack(
          children: [
            _buildCard(),
            // LIKE stamp
            Positioned(
              top: 50,
              left: 30,
              child: Transform.rotate(
                angle: -0.35,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _likeOpacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIKE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // NOPE stamp
            Positioned(
              top: 50,
              right: 30,
              child: Transform.rotate(
                angle: 0.35,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _nopeOpacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NOPE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Swipe up indicator
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: _infoOpacity,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('VIEW DETAILS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDragging ? 0.2 : 0.1),
            blurRadius: _isDragging ? 30 : 20,
            offset: Offset(0, _isDragging ? 15 : 10),
            spreadRadius: _isDragging ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            SafeNetworkImage(
              imageUrl: widget.cow.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price & Verified Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.cow.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ],
                          ),
                        )
                      else
                        const SizedBox(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3A15F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹${_formatPrice(widget.cow.price)}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Name & Breed
                  Text(
                    widget.cow.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.cow.breed,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildStatChip(Icons.cake_outlined, widget.cow.age),
                      _buildStatChip(Icons.water_drop_outlined, widget.cow.yieldAmount),
                      _buildStatChip(Icons.location_on_outlined, widget.cow.location),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Action Buttons
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nope Button
                  _buildActionButton(
                    onTap: _onNopePressed,
                    icon: Icons.close,
                    bgColor: Colors.white,
                    iconColor: Colors.red.shade400,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  // Info Button
                  _buildActionButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileDetailScreen(cow: widget.cow)));
                    },
                    icon: Icons.info_outline,
                    bgColor: const Color(0xFFF0EAE2),
                    iconColor: const Color(0xFF5D3A1A),
                    size: 50,
                  ),
                  const SizedBox(width: 16),
                  // Like Button
                  _buildActionButton(
                    onTap: _onLikePressed,
                    icon: Icons.favorite,
                    bgColor: const Color(0xFF5D3A1A),
                    iconColor: Colors.white,
                    size: 64,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    }
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
