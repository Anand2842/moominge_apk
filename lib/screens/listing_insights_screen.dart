import 'package:flutter/material.dart';
import 'package:moomingle/screens/boost_listing_screen.dart';
import 'package:share_plus/share_plus.dart';

class ListingInsightsScreen extends StatefulWidget {
  const ListingInsightsScreen({super.key});

  @override
  State<ListingInsightsScreen> createState() => _ListingInsightsScreenState();
}

class _ListingInsightsScreenState extends State<ListingInsightsScreen> {
  String _selectedDateRange = 'Last 30 Days';
  bool _weeklyEmailReports = true;
  bool _pushNotifications = true;

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

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Insights Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Weekly Email Reports'),
                subtitle: const Text('Receive insights summary every Monday'),
                value: _weeklyEmailReports,
                activeColor: const Color(0xFFD3A15F),
                onChanged: (v) {
                  setModalState(() => _weeklyEmailReports = v);
                  setState(() => _weeklyEmailReports = v);
                },
              ),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Get notified of significant changes'),
                value: _pushNotifications,
                activeColor: const Color(0xFFD3A15F),
                onChanged: (v) {
                  setModalState(() => _pushNotifications = v);
                  setState(() => _pushNotifications = v);
                },
              ),
              ListTile(
                leading: const Icon(Icons.compare_arrows),
                title: const Text('Compare Listings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compare feature coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportData() async {
    final exportData = '''
Moomingle Listing Insights Report
Date Range: $_selectedDateRange
Generated: ${DateTime.now().toString().split('.')[0]}

SUMMARY
-------
Total Views: 2,548 (+12%)
Right Swipes: 340 (+5%)
Matches: 18 (+2)
Profile Opens: 890 (0%)
Chats Started: 12 (+4)
Conversion Rate: 3.4%

TOP PERFORMING LISTINGS
-----------------------
1. Angus Bull #492 - 214 Views (High Interest)
2. Dairy Heifer 'Bella' - 450 Views (Sold)
''';
    
    await Share.share(exportData, subject: 'Moomingle Insights Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text(
          'Listing Insights',
          style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _showSettings,
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.settings, color: Color(0xFF5D3A1A)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range & Export
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showDateRangePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF5D3A1A)),
                        const SizedBox(width: 6),
                        Text(_selectedDateRange, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _exportData,
                  child: const Text('Export', style: TextStyle(color: Color(0xFFD3A15F), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Total Views Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF88B2A0), Color(0xFFD4E6DD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL VIEWS', style: TextStyle(color: Color(0xFF2D5A47), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up, size: 12, color: Colors.green),
                            Text(' +12%', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('2,548', style: TextStyle(color: Color(0xFF2D5A47), fontSize: 36, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  // Fake chart line
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
                    ),
                    child: CustomPaint(size: const Size(double.infinity, 50), painter: _ChartPainter()),
                  ),
                  const SizedBox(height: 8),
                  Text('Views per day (Aug 1 - Aug 30)', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard('340', 'Right Swipes', Icons.thumb_up, '+5%', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('18', 'Matches', Icons.favorite, '+2', Colors.pink)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('890', 'Profile Opens', Icons.visibility, '0%', Colors.grey)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('12', 'Chats Started', Icons.chat_bubble, '+4', Colors.purple)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Conversion Rate Card
            Container(
              width: double.infinity,
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
                      const Text('Conversion Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: '3.4%', style: TextStyle(color: Color(0xFF2D5A47), fontSize: 24, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' +0.33% vs last week', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Boost Button
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoostListingScreen())),
                       icon: const Icon(Icons.rocket_launch),
                       label: const Text('Boost Profile Visibility'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF3E2723),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 14),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                       ),
                     ),
                   ),
                  const SizedBox(height: 16),
                  // Weekly bar chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
                      double height = [30.0, 40.0, 35.0, 50.0, 60.0, 75.0, 45.0][e.key];
                      bool isHighlight = e.key == 5;
                      return Column(
                        children: [
                          Container(width: 16, height: height, decoration: BoxDecoration(color: isHighlight ? const Color(0xFF3E2723) : const Color(0xFFD3A15F), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 4),
                          Text(e.value, style: TextStyle(fontSize: 10, color: isHighlight ? const Color(0xFF3E2723) : Colors.grey)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Top Performing Listings
            const Text('Top Performing Listings', style: TextStyle(color: Color(0xFF3E2723), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildListingRow('Angus Bull #492', 'Posted 3 days ago', 'High Interest', '214 Views', Colors.orange),
            const SizedBox(height: 12),
            _buildListingRow('Dairy Heifer \'Bella\'', 'Posted 1 week ago', 'Sold', '450 Views', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: changeColor, size: 20),
              Text(change, style: TextStyle(color: changeColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF3E2723))),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildListingRow(String title, String subtitle, String status, String views, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network('https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=100', width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(views, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5A47)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.6, size.width * 0.5, size.height * 0.4)
      ..cubicTo(size.width * 0.7, size.height * 0.1, size.width * 0.85, size.height * 0.5, size.width, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
