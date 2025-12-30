import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/api_service.dart';
import 'package:moomingle/widgets/cow_card.dart';
import 'package:moomingle/screens/filter_screen.dart';
import 'package:moomingle/screens/profile_screen.dart';
import 'package:moomingle/widgets/safe_image.dart';
import 'package:moomingle/models/cow_listing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _activeFilters;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiService>().fetchListings();
    });
  }

  List<CowListing> _applyFilters(List<CowListing> listings) {
    if (_activeFilters == null) return listings;
    
    var filtered = listings;
    
    // Filter by breeds
    final selectedBreeds = _activeFilters!['breeds'] as List<String>?;
    if (selectedBreeds != null && selectedBreeds.isNotEmpty) {
      filtered = filtered.where((cow) => selectedBreeds.contains(cow.breed)).toList();
    }
    
    // Filter by price range
    final priceRange = _activeFilters!['priceRange'] as RangeValues?;
    if (priceRange != null) {
      filtered = filtered.where((cow) => 
        cow.price >= priceRange.start && cow.price <= priceRange.end
      ).toList();
    }
    
    // Filter by verified only
    final verifiedOnly = _activeFilters!['verifiedOnly'] as bool?;
    if (verifiedOnly == true) {
      filtered = filtered.where((cow) => cow.isVerified).toList();
    }
    
    return filtered;
  }

  Future<void> _openFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const FilterScreen()),
    );
    
    if (result != null) {
      setState(() {
        _activeFilters = result;
        _currentIndex = 0; // Reset to first card when filters change
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Filters applied'),
          backgroundColor: const Color(0xFF5D3A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Clear',
            textColor: Colors.white,
            onPressed: () => setState(() {
              _activeFilters = null;
              _currentIndex = 0;
            }),
          ),
        ),
      );
    }
  }

  void _onSwipeLeft() {
    final api = context.read<ApiService>();
    final filteredListings = _applyFilters(api.listings);
    
    setState(() {
      _currentIndex++;
    });
    
    // Auto-load more when 5 cards away from end
    if (_currentIndex >= filteredListings.length - 5 && api.hasMore) {
      api.loadMore();
    }
  }

  void _onSwipeRight() {
    final api = context.read<ApiService>();
    final filteredListings = _applyFilters(api.listings);
    
    // Match is handled in CowCard, just advance the index
    setState(() {
      _currentIndex++;
    });
    
    // Auto-load more when 5 cards away from end
    if (_currentIndex >= filteredListings.length - 5 && api.hasMore) {
      api.loadMore();
    }
  }

  void _undoSwipe() {
    if (_currentIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8B888),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Avatar (Top Left) - Now tappable
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: SafeCircleAvatar(radius: 22, fallbackInitial: 'U'),
                  ),
                  // Title
                  Column(
                    children: [
                      const Text(
                        'Moomingle',
                        style: TextStyle(
                          color: Color(0xFF5D3A1A),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_activeFilters != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3A15F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Filtered', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  // Filter Button (Top Right)
                  GestureDetector(
                    onTap: _openFilters,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _activeFilters != null 
                            ? const Color(0xFFD3A15F) 
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune,
                        color: _activeFilters != null ? Colors.white : const Color(0xFF5D3A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area - Stacked Cards
            Expanded(
              child: Consumer<ApiService>(
                builder: (context, api, child) {
                  if (api.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF5D3A1A)),
                          SizedBox(height: 16),
                          Text('Finding cattle near you...', style: TextStyle(color: Color(0xFF5D3A1A))),
                        ],
                      ),
                    );
                  }

                  if (api.error != null && api.listings.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 64, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(height: 16),
                            Text(
                              api.error!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => api.fetchListings(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D3A1A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredListings = _applyFilters(api.listings);

                  if (filteredListings.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(height: 16),
                            Text(
                              _activeFilters != null 
                                  ? 'No cattle match your filters'
                                  : 'No cattle found in your area!',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _activeFilters != null 
                                  ? 'Try adjusting your filters'
                                  : 'Check back later for new listings',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                            ),
                            if (_activeFilters != null) ...[
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: () => setState(() {
                                  _activeFilters = null;
                                  _currentIndex = 0;
                                }),
                                icon: const Icon(Icons.filter_alt_off),
                                label: const Text('Clear Filters'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  // Auto-load more when approaching end (3 cards before)
                  if (_currentIndex >= filteredListings.length - 3 && api.hasMore && !api.isLoadingMore) {
                    api.loadMore();
                  }

                  // Check if we've gone through all cards
                  if (_currentIndex >= filteredListings.length) {
                    // If still loading more, show spinner
                    if (api.isLoadingMore) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF5D3A1A)),
                            SizedBox(height: 16),
                            Text('Loading more cattle...', style: TextStyle(color: Color(0xFF5D3A1A))),
                          ],
                        ),
                      );
                    }
                    
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🐄', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            const Text(
                              "You've seen all cattle!",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for new listings',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    api.fetchListings(refresh: true);
                                    setState(() => _currentIndex = 0);
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Start Over'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5D3A1A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                ),
                                if (_currentIndex > 0) ...[
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: _undoSwipe,
                                    icon: const Icon(Icons.undo),
                                    label: const Text('Undo'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Build stacked cards (show current + 2 behind)
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background cards (show up to 2 behind)
                      for (int i = (_currentIndex + 2).clamp(0, filteredListings.length - 1); i > _currentIndex; i--)
                        if (i < filteredListings.length)
                          Transform.scale(
                            scale: 1 - (i - _currentIndex) * 0.05,
                            child: Transform.translate(
                              offset: Offset(0, (i - _currentIndex) * 8.0),
                              child: Opacity(
                                opacity: 1 - (i - _currentIndex) * 0.2,
                                child: IgnorePointer(
                                  child: _buildBackgroundCard(filteredListings[i]),
                                ),
                              ),
                            ),
                          ),
                      // Current card (interactive)
                      CowCard(
                        key: ValueKey(filteredListings[_currentIndex].id),
                        cow: filteredListings[_currentIndex],
                        onSwipeLeft: _onSwipeLeft,
                        onSwipeRight: _onSwipeRight,
                      ),
                      // Progress indicator
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        child: _buildProgressIndicator(filteredListings.length),
                      ),
                      // Loading more indicator
                      if (api.isLoadingMore)
                        Positioned(
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D3A1A).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Loading more...', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCard(CowListing cow) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SafeNetworkImage(
          imageUrl: cow.imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int total) {
    final progress = total > 0 ? (_currentIndex / total) : 0.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5D3A1A)),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_currentIndex + 1} of $total',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
