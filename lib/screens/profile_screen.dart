import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moomingle/screens/create_profile_screen.dart';
import 'package:moomingle/screens/seller_settings_screen.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/services/user_profile_service.dart';
import 'package:moomingle/services/settings_service.dart';
import 'package:moomingle/widgets/safe_image.dart';
import 'package:moomingle/config/app_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await context.read<UserProfileService>().fetchProfile();
  }

  void _showPaymentMethods(BuildContext context) {
    if (!AppConfig.enablePayments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment features are not yet available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No payment methods added', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add payment method coming soon!')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<SettingsService>(
        builder: (ctx, settings, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notification Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Match Alerts'),
                  subtitle: const Text('When someone likes your listing'),
                  value: settings.matchAlerts,
                  activeColor: const Color(0xFFD3A15F),
                  onChanged: (v) => settings.setMatchAlerts(v),
                ),
                SwitchListTile(
                  title: const Text('Message Alerts'),
                  subtitle: const Text('New messages from buyers/sellers'),
                  value: settings.messageAlerts,
                  activeColor: const Color(0xFFD3A15F),
                  onChanged: (v) => settings.setMessageAlerts(v),
                ),
                SwitchListTile(
                  title: const Text('Price Drop Alerts'),
                  subtitle: const Text('When saved listings drop in price'),
                  value: settings.priceAlerts,
                  activeColor: const Color(0xFFD3A15F),
                  onChanged: (v) => settings.setPriceAlerts(v),
                ),
                SwitchListTile(
                  title: const Text('Marketing'),
                  subtitle: const Text('Tips and promotional offers'),
                  value: settings.marketingAlerts,
                  activeColor: const Color(0xFFD3A15F),
                  onChanged: (v) => settings.setMarketingAlerts(v),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSavedSearches(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Consumer<SettingsService>(
          builder: (ctx, settings, _) {
            final searches = settings.savedSearches;
            
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saved Searches', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCreateSearchAlert(context);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: searches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('No saved searches yet', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                const Text('Save your filter preferences to get alerts', 
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: searches.length,
                            itemBuilder: (_, index) {
                              final search = searches[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAEEDD),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.search, color: Color(0xFF5D3A1A)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(search.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(
                                            '${search.breeds.isEmpty ? "All breeds" : search.breeds.join(", ")} • ₹${(search.minPrice/1000).toInt()}K-${(search.maxPrice/1000).toInt()}K',
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => settings.removeSavedSearch(search.id),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateSearchAlert(BuildContext context) {
    final nameController = TextEditingController(text: 'My Search');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Search Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Search Name',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Go to the filter screen and apply your preferred filters, then save them as a search alert.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final settings = context.read<SettingsService>();
              settings.addSavedSearch(SavedSearch(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim().isEmpty ? 'My Search' : nameController.text.trim(),
                breeds: [],
                minPrice: 50000,
                maxPrice: 200000,
                maxDistance: 100,
                verifiedOnly: false,
                createdAt: DateTime.now(),
              ));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search alert created!'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723)),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF5D3A1A)),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.pop(ctx);
                _showFAQs(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Color(0xFF5D3A1A)),
              title: const Text('Email Support'),
              subtitle: Text(AppConfig.supportEmail),
              onTap: () async {
                Navigator.pop(ctx);
                final Uri emailUri = Uri(scheme: 'mailto', path: AppConfig.supportEmail);
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined, color: Color(0xFF5D3A1A)),
              title: const Text('Live Chat'),
              subtitle: Text('Available ${AppConfig.supportHours}'),
              onTap: () {
                Navigator.pop(ctx);
                _startLiveChat(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildFAQItem('How do I list my cattle?', 'Go to Seller Hub > Add New Listing. Take photos of your cattle from different angles and fill in the details like breed, age, and price.'),
              _buildFAQItem('Is Moomingle free to use?', 'Yes! Moomingle is completely free for all users. There are no listing fees or commissions.'),
              _buildFAQItem('How does the AI breed detection work?', 'Our AI analyzes photos of your cattle to identify the breed. It supports 50+ Indian cattle and buffalo breeds with high accuracy.'),
              _buildFAQItem('How do I contact a seller?', 'Swipe right on a listing you like to match. Once matched, you can chat directly with the seller.'),
              _buildFAQItem('Is my data secure?', 'Yes, we use industry-standard encryption and never share your personal information with third parties.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 8),
          Text(answer, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _startLiveChat(BuildContext context) {
    // Check if within support hours
    final now = DateTime.now();
    final hour = now.hour;
    final isWithinHours = hour >= 9 && hour < 18;
    
    if (!isWithinHours) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Live chat is available ${AppConfig.supportHours}. Please email us at ${AppConfig.supportEmail}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Show live chat interface
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LiveChatWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      body: SafeArea(
        child: Consumer2<UserProfileService, AuthService>(
          builder: (context, profileService, authService, _) {
            final profile = profileService.profile;
            final isLoading = profileService.isLoading;

            if (isLoading && profile == null) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD3A15F)));
            }

            return RefreshIndicator(
              onRefresh: _loadProfile,
              color: const Color(0xFFD3A15F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerSettingsScreen())),
                          icon: const Icon(Icons.settings, color: Color(0xFF5D3A1A)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF6EE),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SafeCircleAvatar(
                                radius: 50, 
                                imageUrl: profile?.avatarUrl,
                                fallbackInitial: profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'U',
                              ),
                              Positioned(
                                bottom: 4, right: 4,
                                child: Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(
                                    color: authService.isAuthenticated ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile?.name ?? 'User',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                          ),
                          const SizedBox(height: 4),
                          if (profile?.location != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Color(0xFFD3A15F)),
                                const SizedBox(width: 4),
                                Text(profile!.location!, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                          if (profile?.email != null) ...[
                            const SizedBox(height: 4),
                            Text(profile!.email!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAEEDD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getRoleBadge(profile?.role ?? 'both'),
                              style: const TextStyle(color: Color(0xFFD3A15F), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (authService.isDemoMode) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('DEMO MODE', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('${profile?.activeBids ?? 0}', 'Active Bids'),
                          Container(width: 1, height: 40, color: Colors.grey[200]),
                          _buildStat('${profile?.purchased ?? 0}', 'Purchased'),
                          Container(width: 1, height: 40, color: Colors.grey[200]),
                          _buildStat('${profile?.favorites ?? 0}', 'Favorites'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Account Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ACCOUNT', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(context, Icons.edit, 'Edit Profile', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProfileScreen()))),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(context, Icons.payment, 'Payment Methods', () => _showPaymentMethods(context)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Preferences Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('PREFERENCES', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(context, Icons.notifications, 'Notification Settings', () => _showNotificationSettings(context)),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(context, Icons.bookmark, 'Saved Searches', () => _showSavedSearches(context)),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(context, Icons.help, 'Help & Support', () => _showHelpSupport(context)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Log Out'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            context.read<UserProfileService>().clearProfile();
                            await context.read<AuthService>().signOut();
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide.none,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Text('${AppConfig.appName} v${AppConfig.appVersion}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

  String _getRoleBadge(String role) {
    switch (role.toLowerCase()) {
      case 'buyer':
        return 'BUYER';
      case 'seller':
        return 'SELLER';
      case 'both':
      default:
        return 'BUYER & SELLER';
    }
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAEEDD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF5D3A1A), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF3E2723))),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}

/// Live Chat Widget for customer support
class _LiveChatWidget extends StatefulWidget {
  @override
  State<_LiveChatWidget> createState() => _LiveChatWidgetState();
}

class _LiveChatWidgetState extends State<_LiveChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! Welcome to Moomingle Support. How can I help you today?', 'isMe': false, 'time': 'Now'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'Now',
      });
    });
    
    final userMessage = _messageController.text.trim().toLowerCase();
    _messageController.clear();
    
    // Simulate support response after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': _getAutoResponse(userMessage),
            'isMe': false,
            'time': 'Now',
          });
        });
      }
    });
  }

  String _getAutoResponse(String message) {
    if (message.contains('price') || message.contains('cost') || message.contains('free')) {
      return 'Moomingle is completely free to use! There are no listing fees, commissions, or hidden charges.';
    } else if (message.contains('list') || message.contains('sell')) {
      return 'To list your cattle, go to the Seller Hub and tap "Add New Listing". You can take photos and fill in details like breed, age, and price.';
    } else if (message.contains('buy') || message.contains('purchase')) {
      return 'To buy cattle, browse listings on the home screen and swipe right on ones you like. Once matched, you can chat directly with the seller!';
    } else if (message.contains('breed') || message.contains('ai') || message.contains('detect')) {
      return 'Our AI breed detection analyzes photos to identify cattle breeds. It supports 50+ Indian breeds including Gir, Murrah, Sahiwal, and more!';
    } else if (message.contains('contact') || message.contains('call') || message.contains('phone')) {
      return 'You can request a seller\'s phone number through the chat. They\'ll share it if they\'re interested in discussing further.';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with?';
    } else {
      return 'Thanks for your message! A support agent will review this and get back to you shortly. For urgent matters, email us at ${AppConfig.supportEmail}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFD3A15F),
                child: Icon(Icons.support_agent, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Moomingle Support', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          
          // Messages
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF5D3A1A) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD3A15F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
