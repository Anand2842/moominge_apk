import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Privacy Policy', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
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
              Text('Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Text('Last updated: December 2025', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 24),
              
              Text('1. Information We Collect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'Moomingle collects information you provide directly, including:\n'
                '• Account information (name, phone number, location)\n'
                '• Listing details (cattle photos, breed, price, location)\n'
                '• Messages exchanged with other users\n'
                '• Device information for app functionality',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('2. How We Use Your Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'We use collected information to:\n'
                '• Provide and improve our marketplace services\n'
                '• Connect buyers with sellers\n'
                '• Verify listings using AI breed classification\n'
                '• Send notifications about matches and messages\n'
                '• Ensure platform safety and prevent fraud',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('3. Information Sharing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'We share information only:\n'
                '• With other users when you match or message\n'
                '• With service providers who assist our operations\n'
                '• When required by law or to protect rights\n'
                '• We never sell your personal data to third parties',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('4. Data Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'We implement industry-standard security measures including encryption, secure servers, and regular security audits to protect your data.',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('5. Your Rights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'You have the right to:\n'
                '• Access your personal data\n'
                '• Correct inaccurate information\n'
                '• Delete your account and data\n'
                '• Opt out of marketing communications',
                style: TextStyle(color: Color(0xFF5D3A1A), height: 1.6),
              ),
              SizedBox(height: 20),
              
              Text('6. Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Text(
                'For privacy concerns, contact us at:\n'
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
