import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/add_cattle_screen.dart';
import 'package:moomingle/screens/performance_screen.dart';
import 'package:moomingle/screens/listing_status_screen.dart';
import 'package:moomingle/screens/my_listings_screen.dart';
import 'package:moomingle/screens/chats_screen.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/services/user_profile_service.dart';
import 'package:moomingle/services/seller_stats_service.dart';
import 'package:moomingle/services/settings_service.dart';

class SellerHubScreen extends StatefulWidget {
  const SellerHubScreen({super.key});

  @override
  State<SellerHubScreen> createState() => _SellerHubScreenState();
}

class _SellerHubScreenState extends State<SellerHubScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    final profileService = context.read<UserProfileService>();
    final sellerStats = context.read<SellerStatsService>();
    
    await profileService.fetchProfile();
    await sellerStats.fetchSellerListings(auth.user?.id);
    await sellerStats.fetchNotifications(auth.user?.id);
  }

  void _showNotifications() {
    final sellerStats = context.read<SellerStatsService>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<SellerStatsService>(
        builder: (ctx, stats, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => sellerStats.markAllNotificationsRead(),
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (stats.notifications.isEmpty)
                const Center(child: Text('No notifications', style: TextStyle(color: Colors.grey)))
              else
                ...stats.notifications.take(5).map((n) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: n.read ? Colors.grey[100] : const Color(0xFFFAEEDD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(n.type),
                      color: n.read ? Colors.grey : const Color(0xFFD3A15F),
                      size: 20,
                    ),
                  ),
                  title: Text(n.title, style: TextStyle(
                    fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                  )),
                  subtitle: Text(n.body, style: const TextStyle(fontSize: 12)),
                  trailing: Text(n.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  onTap: () => sellerStats.markNotificationRead(n.id),
                )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'match':
        return Icons.favorite;
      case 'price_alert':
        return Icons.trending_up;
      case 'expiring':
        return Icons.timer;
      case 'message':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  void _showEditDashboard() {
    final settingsService = context.read<SettingsService>();
    Map<String, bool> tempItems = Map.from(settingsService.dashboardItems);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customize Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Toggle widgets on/off', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ...tempItems.entries.map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.drag_handle, color: Colors.grey),
                title: Text(e.key),
                trailing: Switch(
                  value: e.value,
                  activeColor: const Color(0xFFD3A15F),
                  onChanged: (v) {
                    setModalState(() => tempItems[e.key] = v);
                  },
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await settingsService.updateDashboardItems(tempItems);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dashboard settings saved!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      body: SafeArea(
        child: Consumer3<UserProfileService, SellerStatsService, AuthService>(
          builder: (context, profileService, sellerStats, auth, _) {
            final profile = profileService.profile;
            final isLoading = profileService.isLoading || sellerStats.isLoading;

            return RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFD3A15F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFD3A15F),
                          child: Text(
                            profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Howdy, ${profile?.name.split(' ').first ?? 'Seller'}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                              ),
                              const Text('Welcome to your hub', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: _showNotifications,
                              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF5D3A1A)),
                            ),
                            if (sellerStats.unreadNotifications > 0)
                              Positioned(
                                right: 8, top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: Text(
                                    '${sellerStats.unreadNotifications}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Badges
                    Row(
                      children: [
                        if (profile?.tier != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getTierColor(profile!.tier!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '${profile.tier!.toUpperCase()} TIER SELLER',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        if (profile?.tier != null) const SizedBox(width: 10),
                        if (profile?.isVerified == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green, size: 16),
                                SizedBox(width: 6),
                                Text('ID VERIFIED', style: TextStyle(color: Color(0xFF3E2723), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        if (auth.isDemoMode)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('DEMO MODE', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // My Cattle Hub Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Cattle Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                        TextButton(onPressed: _showEditDashboard, child: const Text('Edit Dashboard', style: TextStyle(color: Color(0xFFD3A15F)))),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Actions Grid
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD3A15F),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 32),
                                  SizedBox(height: 8),
                                  Text('List Cattle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('Add to marketplace', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyListingsScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.inventory_2, color: Color(0xFF5D3A1A)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                                        child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${sellerStats.activeListingsCount}',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                                  ),
                                  const Text('My Listings', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatsScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      const Icon(Icons.chat_bubble_outline, color: Color(0xFF5D3A1A)),
                                      if (sellerStats.interestedBuyers > 0)
                                        Positioned(
                                          right: -2, top: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            child: Text(
                                              '${sellerStats.interestedBuyers}',
                                              style: const TextStyle(color: Colors.white, fontSize: 10),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Interested Buyers', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                  Text(
                                    sellerStats.newBuyersToday > 0 
                                        ? '${sellerStats.newBuyersToday} new today'
                                        : 'No new inquiries',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformanceScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.bar_chart, color: Color(0xFF5D3A1A)),
                                  const SizedBox(height: 8),
                                  const Text('View Stats', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                  Text(
                                    '${sellerStats.totalViews} total views',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    
                    if (sellerStats.listings.isEmpty && !isLoading)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text('No listings yet', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                            const SizedBox(height: 4),
                            const Text('Create your first listing to start selling', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD3A15F),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Add Listing', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    else if (sellerStats.totalViews > 0)
                      _buildActivityTile(
                        Icons.visibility,
                        'Listing Views',
                        '${sellerStats.totalViews} total views across all listings',
                        'All time',
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformanceScreen())),
                      ),
                    
                    if (sellerStats.interestedBuyers > 0) ...[
                      const SizedBox(height: 10),
                      _buildActivityTile(
                        Icons.favorite,
                        'Interested Buyers',
                        '${sellerStats.interestedBuyers} buyers have shown interest',
                        '',
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatsScreen())),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold':
        return const Color(0xFFD4A853);
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFFD3A15F);
    }
  }

  Widget _buildActivityTile(IconData icon, String title, String subtitle, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFFAEEDD), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFF5D3A1A), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (time.isNotEmpty)
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
