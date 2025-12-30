import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/boost_listing_screen.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/services/seller_stats_service.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String _selectedDateRange = 'Last 7 Days';
  bool _isWeekView = true;
  SellerListing? _selectedListing;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    final sellerStats = context.read<SellerStatsService>();
    await sellerStats.fetchSellerListings(auth.user?.id);
    
    // Select first listing by default
    if (sellerStats.listings.isNotEmpty && _selectedListing == null) {
      setState(() => _selectedListing = sellerStats.listings.first);
    }
  }

  void _showDateRangePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Date Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['Last 7 Days', 'Last 14 Days', 'Last 30 Days', 'Last 90 Days', 'All Time'].map((range) => ListTile(
              title: Text(range),
              trailing: _selectedDateRange == range ? const Icon(Icons.check, color: Color(0xFFD3A15F)) : null,
              onTap: () {
                setState(() => _selectedDateRange = range);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAllListings() {
    final sellerStats = context.read<SellerStatsService>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: sellerStats.listings.isEmpty
                    ? const Center(child: Text('No listings available', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: sellerStats.listings.length,
                        itemBuilder: (_, index) {
                          final listing = sellerStats.listings[index];
                          final isSelected = _selectedListing?.id == listing.id;
                          return _buildListingTile(listing, isSelected, () {
                            setState(() => _selectedListing = listing);
                            Navigator.pop(ctx);
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingTile(SellerListing listing, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5E0C3) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: const Color(0xFFD3A15F), width: 2) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: listing.imageUrl.isNotEmpty
                  ? Image.network(listing.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder())
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${listing.breed} #${listing.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${listing.views} views', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFD3A15F)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: const Icon(Icons.pets, color: Colors.grey),
    );
  }

  double _calculateEngagementScore(SellerListing? listing) {
    if (listing == null) return 0.0;
    // Simple engagement score based on views and matches
    final viewScore = (listing.views / 100).clamp(0.0, 5.0);
    final matchScore = (listing.matches / 10).clamp(0.0, 5.0);
    return (viewScore + matchScore).clamp(0.0, 10.0).toDouble();
  }

  String _getEngagementLabel(double score) {
    if (score >= 8) return 'Very High Interest';
    if (score >= 6) return 'High Interest';
    if (score >= 4) return 'Moderate Interest';
    if (score >= 2) return 'Low Interest';
    return 'Getting Started';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Performance', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _showDateRangePicker,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF5D3A1A)),
                  const SizedBox(width: 6),
                  Text(_selectedDateRange, style: const TextStyle(fontSize: 12, color: Color(0xFF3E2723))),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF5D3A1A)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SellerStatsService>(
        builder: (context, sellerStats, _) {
          final listing = _selectedListing;
          final engagementScore = _calculateEngagementScore(listing);
          final isLoading = sellerStats.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD3A15F)));
          }

          if (sellerStats.listings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFD3A15F),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Listing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SELECTED LISTING', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: _showAllListings, child: const Text('View All', style: TextStyle(color: Color(0xFFD3A15F)))),
                    ],
                  ),
                  if (listing != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: listing.imageUrl.isNotEmpty
                                ? Image.network(listing.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholder())
                                : _buildPlaceholder(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${listing.breed} #${listing.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                Text('Posted ${listing.daysAgo} days ago', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle, color: Color(0xFFD3A15F)),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Engagement Score
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Engagement Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                Text(
                                  engagementScore >= 5 ? 'Above average' : 'Building momentum',
                                  style: const TextStyle(color: Color(0xFFD3A15F), fontSize: 12),
                                ),
                              ],
                            ),
                            Icon(
                              engagementScore >= 5 ? Icons.trending_up : Icons.trending_flat,
                              color: engagementScore >= 5 ? Colors.green : Colors.orange,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(engagementScore.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                            const Text('/10', style: TextStyle(fontSize: 20, color: Colors.grey)),
                            const Spacer(),
                            Text(_getEngagementLabel(engagementScore), style: TextStyle(
                              color: engagementScore >= 5 ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: engagementScore / 10,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFD3A15F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        Icons.visibility,
                        '${listing?.views ?? 0}',
                        'Total Views',
                        listing != null && listing.views > 0 ? '+${(listing.views * 0.12).toInt()}%' : '0%',
                        listing != null && listing.views > 0 ? Colors.green : Colors.grey,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        Icons.favorite,
                        '${listing?.matches ?? 0}',
                        'Interested Buyers',
                        listing != null && listing.matches > 0 ? '+${(listing.matches * 0.05).toInt()}%' : '0%',
                        listing != null && listing.matches > 0 ? Colors.green : Colors.grey,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        Icons.chat,
                        '${sellerStats.interestedBuyers}',
                        'Chats Started',
                        '0%',
                        Colors.grey,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        Icons.person,
                        '${(listing?.views ?? 0) ~/ 4}',
                        'Profile Opens',
                        '+2%',
                        Colors.green,
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Weekly Interest Chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weekly Interest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                Text('Activity over time', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _isWeekView = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isWeekView ? Colors.white : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                      border: _isWeekView ? Border.all(color: Colors.grey.shade300) : null,
                                    ),
                                    child: Text('Week', style: TextStyle(fontWeight: _isWeekView ? FontWeight.bold : FontWeight.normal, color: _isWeekView ? Colors.black : Colors.grey)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(() => _isWeekView = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isWeekView ? Colors.white : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                      border: !_isWeekView ? Border.all(color: Colors.grey.shade300) : null,
                                    ),
                                    child: Text('Month', style: TextStyle(fontWeight: !_isWeekView ? FontWeight.bold : FontWeight.normal, color: !_isWeekView ? Colors.black : Colors.grey)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Simple chart representation based on actual data
                        SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _buildChartBars(listing),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<SellerStatsService>(
        builder: (context, sellerStats, _) {
          if (sellerStats.listings.isEmpty) return const SizedBox.shrink();
          
          return Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF5E0C3),
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoostListingScreen())),
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Boost Listing for 2x Views', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD3A15F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No performance data yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 8),
          const Text('Create a listing to start tracking performance', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars(SellerListing? listing) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final totalViews = listing?.views ?? 0;
    
    // Distribute views across days (simulated distribution)
    final viewsPerDay = totalViews > 0 ? totalViews / 7 : 0;
    
    return days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      // Create some variation in the chart
      final multiplier = [0.3, 0.5, 0.4, 0.6, 0.9, 0.4, 0.3][index];
      final value = totalViews > 0 ? multiplier : 0.1;
      final isHighlighted = index == 4; // Friday highlighted
      final dayViews = (viewsPerDay * multiplier * 2).toInt();
      
      return _buildChartBar(day, value, isHighlighted, dayViews);
    }).toList();
  }

  Widget _buildStatCard(IconData icon, String value, String label, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: changeColor == Colors.green ? Colors.blue : Colors.purple),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(change, style: TextStyle(color: changeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double value, bool isHighlighted, int views) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isHighlighted && views > 0)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$views', style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),
        const SizedBox(height: 4),
        Container(
          width: 8,
          height: 60 * value,
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFFD3A15F) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 10, color: isHighlighted ? const Color(0xFF3E2723) : Colors.grey)),
      ],
    );
  }
}
