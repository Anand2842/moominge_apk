import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/analytics_service.dart';

/// Analytics Dashboard Screen
/// Shows app metrics, user engagement, and performance data
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  Map<String, dynamic>? _engagement;
  List<Map<String, dynamic>> _popularListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    final analytics = context.read<AnalyticsService>();
    
    final engagement = await analytics.getUserEngagement();
    final popular = await analytics.getPopularListings(limit: 5);

    setState(() {
      _engagement = engagement;
      _popularListings = popular;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: const Color(0xFF8B5A2B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildEngagementCard(),
                  const SizedBox(height: 16),
                  _buildPopularListingsCard(),
                  const SizedBox(height: 16),
                  _buildQuickStatsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildEngagementCard() {
    if (_engagement == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No engagement data available'),
        ),
      );
    }

    final totalViews = _engagement!['total_views'] ?? 0;
    final totalLikes = _engagement!['total_likes'] ?? 0;
    final totalChats = _engagement!['total_chats'] ?? 0;
    final totalOffers = _engagement!['total_offers'] ?? 0;
    final score = _engagement!['engagement_score'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF8B5A2B), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Your Engagement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Views', totalViews.toString(), Icons.visibility),
                _buildStatItem('Likes', totalLikes.toString(), Icons.favorite),
                _buildStatItem('Chats', totalChats.toString(), Icons.chat),
                _buildStatItem('Offers', totalOffers.toString(), Icons.local_offer),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A2B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Color(0xFF8B5A2B)),
                  const SizedBox(width: 8),
                  Text(
                    'Engagement Score: ${score.toString()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A2B),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B5A2B), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5A2B),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularListingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.whatshot, color: Color(0xFF8B5A2B), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Popular Listings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_popularListings.isEmpty)
              const Text('No popular listings data available')
            else
              ..._popularListings.map((listing) => _buildListingItem(listing)),
          ],
        ),
      ),
    );
  }

  Widget _buildListingItem(Map<String, dynamic> listing) {
    final name = listing['name'] ?? 'Unknown';
    final breed = listing['breed'] ?? '';
    final views = listing['views'] ?? 0;
    final likes = listing['likes'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  breed,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.visibility, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$views'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('$likes'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF8B5A2B), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuickStatRow('Active Users', 'Real-time tracking enabled'),
            _buildQuickStatRow('Error Monitoring', 'Automatic error logging'),
            _buildQuickStatRow('Performance', 'Analytics tracking active'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
