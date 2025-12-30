import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/performance_screen.dart';
import 'package:moomingle/screens/add_cattle_screen.dart';
import 'package:moomingle/screens/boost_listing_screen.dart';
import 'package:moomingle/screens/edit_listing_screen.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/services/seller_stats_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final auth = context.read<AuthService>();
    await context.read<SellerStatsService>().fetchSellerListings(auth.user?.id);
  }

  List<SellerListing> _getFilteredListings(List<SellerListing> listings) {
    var filtered = listings;
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((l) {
        final breed = l.breed.toLowerCase();
        final id = l.id.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return breed.contains(query) || id.contains(query);
      }).toList();
    }
    
    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((l) => 
        l.status.toLowerCase() == _selectedFilter.toLowerCase()
      ).toList();
    }
    
    return filtered;
  }

  int _getCountForFilter(List<SellerListing> listings, String filter) {
    if (filter == 'All') return listings.length;
    return listings.where((l) => 
      l.status.toLowerCase() == filter.toLowerCase()
    ).length;
  }

  void _showListingOptions(SellerListing listing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${listing.breed} #${listing.id}', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF5D3A1A)),
              title: const Text('Edit Listing'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => EditListingScreen(listing: listing)),
                ).then((updated) {
                  if (updated == true) _loadListings();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.rocket_launch, color: Color(0xFFD3A15F)),
              title: const Text('Boost Listing (Free)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🚀 Listing boosted! It will appear higher in search results.'), backgroundColor: Colors.green),
                );
              },
            ),
            ListTile(
              leading: Icon(
                listing.status.toLowerCase() == 'paused' ? Icons.play_circle : Icons.pause_circle, 
                color: Colors.orange,
              ),
              title: Text(listing.status.toLowerCase() == 'paused' ? 'Activate Listing' : 'Pause Listing'),
              onTap: () async {
                Navigator.pop(ctx);
                final newStatus = listing.status.toLowerCase() == 'paused' ? 'active' : 'paused';
                final sellerStats = context.read<SellerStatsService>();
                final success = await sellerStats.toggleListingStatus(listing.id, newStatus);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newStatus == 'paused' ? 'Listing paused' : 'Listing activated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Listing', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(listing);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(SellerListing listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: Text('Are you sure you want to delete ${listing.breed} #${listing.id}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final sellerStats = context.read<SellerStatsService>();
              final success = await sellerStats.deleteListing(listing.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toInt()}K';
    }
    return '₹${price.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search listings...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('My Listings', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFF5D3A1A)),
          ),
        ],
      ),
      body: Consumer<SellerStatsService>(
        builder: (context, sellerStats, _) {
          final allListings = sellerStats.listings;
          final filteredListings = _getFilteredListings(allListings);
          final isLoading = sellerStats.isLoading;

          return RefreshIndicator(
            onRefresh: _loadListings,
            color: const Color(0xFFD3A15F),
            child: Column(
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', allListings),
                        const SizedBox(width: 8),
                        _buildFilterChip('Active', allListings),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending', allListings),
                        const SizedBox(width: 8),
                        _buildFilterChip('Sold', allListings),
                      ],
                    ),
                  ),
                ),
                
                // Listings Grid
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFD3A15F)))
                      : filteredListings.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: filteredListings.length,
                              itemBuilder: (context, index) => _buildListingCard(context, filteredListings[index]),
                            ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen())),
        backgroundColor: const Color(0xFFD3A15F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No listings found for "$_searchQuery"'
                : _selectedFilter != 'All'
                    ? 'No ${_selectedFilter.toLowerCase()} listings'
                    : 'No listings yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (_selectedFilter == 'All' && _searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Create your first listing to start selling',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Add Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3A15F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, List<SellerListing> allListings) {
    final isSelected = _selectedFilter == label;
    final count = _getCountForFilter(allListings, label);
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3E2723) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF3E2723),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.grey,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, SellerListing listing) {
    Color statusColor;
    String statusText;
    switch (listing.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'sold':
        statusColor = Colors.grey;
        statusText = 'Sold';
        break;
      case 'paused':
        statusColor = Colors.blue;
        statusText = 'Paused';
        break;
      default:
        statusColor = Colors.grey;
        statusText = listing.status;
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformanceScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: listing.imageUrl.isNotEmpty
                      ? Image.network(
                          listing.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showListingOptions(listing),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_horiz, size: 16, color: Color(0xFF5D3A1A)),
                    ),
                  ),
                ),
              ],
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${listing.breed} #${listing.id}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(_formatPrice(listing.price), 
                    style: const TextStyle(color: Color(0xFFD3A15F), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${listing.views}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${listing.matches}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (listing.status.toLowerCase() == 'active')
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoostListingScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAEEDD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch, size: 14, color: Color(0xFFD3A15F)),
                            SizedBox(width: 6),
                            Text('Boost', style: TextStyle(color: Color(0xFFD3A15F), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.pets, size: 40, color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
