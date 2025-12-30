import 'package:flutter/material.dart';
import 'package:moomingle/screens/add_cattle_screen.dart';

class ListingStatusScreen extends StatefulWidget {
  const ListingStatusScreen({super.key});

  @override
  State<ListingStatusScreen> createState() => _ListingStatusScreenState();
}

class _ListingStatusScreenState extends State<ListingStatusScreen> {
  void _showHelp() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Update Help', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Why do I need to update weekly?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Weekly updates help buyers know your livestock is still available and healthy. It builds trust and increases your chances of making a sale.'),
            const SizedBox(height: 16),
            const Text('What photo should I upload?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Take a clear photo of the animal\'s muzzle (nose area). This unique pattern helps verify identity and freshness of the listing.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Got it', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _remindLater() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('We\'ll remind you in 1 hour'), backgroundColor: Color(0xFFD3A15F)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.close, color: Color(0xFF5D3A1A)),
          ),
        ),
        title: const Text('Listing Status', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(onPressed: _showHelp, child: const Text('Help', style: TextStyle(color: Color(0xFFD3A15F)))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber, color: Colors.orange, size: 40),
            ),
            
            const SizedBox(height: 24),
            
            const Text('Weekly Update Required', 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
            ),
            const SizedBox(height: 8),
            const Text('Time remaining to keep your listing\nactive in the deck.', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 24),
            
            // Countdown Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeUnit('01', 'DAYS'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(':', style: TextStyle(fontSize: 30, color: Color(0xFF3E2723))),
                  ),
                  _buildTimeUnit('23', 'HRS'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(':', style: TextStyle(fontSize: 30, color: Color(0xFF3E2723))),
                  ),
                  _buildTimeUnit('45', 'MINS'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Update Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info, color: Colors.blue, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Weekly update pending — upload a new ',
                            children: [
                              TextSpan(text: 'muzzle photo', style: TextStyle(color: Color(0xFFD3A15F), fontWeight: FontWeight.bold)),
                              TextSpan(text: ' to verify availability.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Photo comparison
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=150',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('LAST WEEK', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.arrow_forward, color: Colors.grey),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAEEDD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD3A15F), style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Color(0xFFD3A15F)),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('NEW PHOTO', style: TextStyle(fontSize: 10, color: Color(0xFFD3A15F), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Taking a new photo takes less than 30 seconds.', 
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pro Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFFAEEDD),
                    radius: 20,
                    child: Text('💡', style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Pro Tip: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: 'Verified recent listings get ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: '3x more matches',
                            style: TextStyle(color: Color(0xFFD3A15F), fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' on average.',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF5E0C3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCattleScreen())),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Update Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _remindLater,
              child: const Text('Remind me in 1 hour', style: TextStyle(color: Color(0xFFD3A15F))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAEEDD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
