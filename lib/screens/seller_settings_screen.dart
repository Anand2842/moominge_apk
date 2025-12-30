import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/screens/listing_insights_screen.dart';
import 'package:moomingle/screens/verification_status_screen.dart';
import 'package:moomingle/services/auth_service.dart';
import 'package:moomingle/services/settings_service.dart';
import 'package:moomingle/config/app_config.dart';

class SellerSettingsScreen extends StatefulWidget {
  const SellerSettingsScreen({super.key});

  @override
  State<SellerSettingsScreen> createState() => _SellerSettingsScreenState();
}

class _SellerSettingsScreenState extends State<SellerSettingsScreen> {
  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Ranch Name',
                hintText: 'Sunny Side Ranch',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell buyers about your ranch...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Current Password', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'New Password', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Confirm New Password', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated'), backgroundColor: Colors.green));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Update Password', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Color(0xFFD3A15F)),
              title: const Text('Bank Account'),
              subtitle: const Text('HDFC ****4521'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Color(0xFFD3A15F)),
              title: const Text('UPI'),
              subtitle: const Text('ranch@upi'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add payment method coming soon')));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD3A15F), side: const BorderSide(color: Color(0xFFD3A15F))),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Default Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'City/Town', hintText: 'Austin', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'State', hintText: 'TX', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated'), backgroundColor: Colors.green));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Save Location', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.email, color: Color(0xFFD3A15F)), title: const Text('Email Support'), subtitle: Text(AppConfig.supportEmail), onTap: () => Navigator.pop(ctx)),
            ListTile(leading: const Icon(Icons.phone, color: Color(0xFFD3A15F)), title: const Text('Call Us'), subtitle: Text(AppConfig.supportPhone), onTap: () => Navigator.pop(ctx)),
            ListTile(leading: const Icon(Icons.chat, color: Color(0xFFD3A15F)), title: const Text('Live Chat'), subtitle: Text('Available ${AppConfig.supportHours}'), onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Seller Settings', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD3A15F)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(AppConfig.defaultAvatarUrl),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sunny Side Ranch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Manage your seller profile', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => _showEditProfileModal(), icon: const Icon(Icons.chevron_right, color: Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings
            const Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            _buildSettingsTile(Icons.edit, 'Edit Profile', onTap: () => _showEditProfileModal()),
            _buildSettingsTile(Icons.lock, 'Change Password', onTap: () => _showChangePasswordModal()),
            _buildSettingsTile(Icons.credit_card, 'Payment Methods', onTap: () => _showPaymentMethodsModal()),
            
            const SizedBox(height: 24),
            
            // Listing Preferences
            const Text('LISTING PREFERENCES', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            _buildSettingsTile(Icons.location_on, 'Default Location', subtitle: 'Austin, TX', onTap: () => _showLocationModal()),
            Consumer<SettingsService>(
              builder: (context, settings, _) => _buildToggleTile(
                Icons.sync, 'Auto-relist', 'Automatically repost unsold\nlivestock after 30 days', 
                settings.autoRelist, (v) => settings.setAutoRelist(v),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notifications
            const Text('NOTIFICATIONS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Consumer<SettingsService>(
              builder: (context, settings, _) => Column(
                children: [
                  _buildToggleTile(Icons.chat_bubble, 'Chat Alerts', null, settings.chatAlerts, (v) => settings.setChatAlerts(v)),
                  _buildToggleTile(Icons.analytics, 'Market Analytics', null, settings.marketAnalytics, (v) => settings.setMarketAnalytics(v)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => _showPrivacyPolicy(), child: const Text('Privacy Policy', style: TextStyle(color: Colors.grey))),
                TextButton(onPressed: () => _showHelpSupport(), child: const Text('Help & Support', style: TextStyle(color: Colors.grey))),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Log Out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
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
                    await context.read<AuthService>().signOut();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3E2723),
                  side: const BorderSide(color: Color(0xFFD7C7B2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Log Out'),
              ),
            ),
            
            const SizedBox(height: 12),
            const Center(child: Text('Moomingle v1.0.4', style: TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-cattle'),
        backgroundColor: const Color(0xFFD3A15F),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.style, 'Swipe', false),
              _buildNavItem(Icons.chat_bubble, 'Chat', false),
              const SizedBox(width: 40), // Space for FAB
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingInsightsScreen())),
                child: _buildNavItem(Icons.storefront, 'Orders', false),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationStatusScreen())),
                child: _buildNavItem(Icons.settings, 'Settings', true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFFFAEEDD), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF5D3A1A), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String title, String? subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFFFAEEDD), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF5D3A1A), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4285F4),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF5D3A1A) : Colors.grey, size: 24),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF5D3A1A) : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
