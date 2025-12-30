import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Terms of Service', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms of Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Text('Last updated: December 2025', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 24),
              
              Text('1. Acceptance of Terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'By accessing or using Moomingle, you agree to be bound by these Terms of Service. If you do not agree, please do not use our services.',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('2. Eligibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'You must be at least 18 years old and legally able to enter into contracts to use Moomingle. By using our service, you represent that you meet these requirements.',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('3. User Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                '• You are responsible for maintaining account security\n'
                '• Provide accurate and complete information\n'
                '• One account per person\n'
                '• Do not share your account credentials',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('4. Listing Guidelines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'When creating listings, you must:\n'
                '• Provide accurate descriptions and photos\n'
                '• Only list cattle/buffalo you legally own\n'
                '• Comply with all applicable animal trade laws\n'
                '• Not engage in fraudulent or misleading practices\n'
                '• Ensure animals are healthy and properly cared for',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('5. Prohibited Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'You may not:\n'
                '• Post false or misleading information\n'
                '• Harass or abuse other users\n'
                '• Attempt to circumvent platform fees\n'
                '• Use the platform for illegal activities\n'
                '• Scrape or collect user data',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('6. Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'Moomingle facilitates connections between buyers and sellers. We are not a party to transactions and do not guarantee the quality, safety, or legality of listed animals. Users transact at their own risk.',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('7. AI Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'Our AI breed classification is provided as a helpful tool but is not guaranteed to be 100% accurate. Users should verify breed information independently before completing transactions.',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('8. Limitation of Liability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'Moomingle is provided "as is" without warranties. We are not liable for any damages arising from your use of the platform or transactions with other users.',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('9. Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'For questions about these terms:\n'
                'Email: stufi339@gmail.com\n'
                'Address: India',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
