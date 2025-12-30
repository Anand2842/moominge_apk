import 'package:flutter/material.dart';
import 'package:moomingle/screens/muzzle_capture_screen.dart';
import 'package:moomingle/services/muzzle_service.dart';

class ListingVerificationScreen extends StatefulWidget {
  final String? listingId;
  final String? animalName;

  const ListingVerificationScreen({
    super.key,
    this.listingId,
    this.animalName,
  });

  @override
  State<ListingVerificationScreen> createState() => _ListingVerificationScreenState();
}

class _ListingVerificationScreenState extends State<ListingVerificationScreen> {
  bool _muzzleVerified = false;
  final bool _photoQualityPassed = true;
  final bool _breedVerified = false;
  final bool _sellerVerified = false;
  String? _muzzleId;

  String get _listingId => widget.listingId ?? 'demo-listing-001';

  int get _completedSteps {
    int count = 0;
    if (_muzzleVerified) count++;
    if (_photoQualityPassed) count++;
    if (_breedVerified) count++;
    if (_sellerVerified) count++;
    return count;
  }

  double get _verificationProgress => _completedSteps / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Verification Status', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Verified listings get ',
                        children: [
                          TextSpan(text: '3x more views', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' from buyers.'),
                        ],
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Icon(Icons.close, color: Colors.grey, size: 18),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Progress Circle
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: _verificationProgress,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation(Color(0xFFD3A15F)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${(_verificationProgress * 100).toInt()}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                              const Text('VERIFIED', style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _verificationProgress >= 1.0 ? 'Gold Badge!' : 'Almost Gold!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                    ),
                    Text(
                      _verificationProgress >= 1.0
                          ? 'All verification steps complete!'
                          : 'Complete the final steps to\nunlock the Gold Badge.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Required Steps
            const Text('Required Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 16),
            
            _buildVerificationStep(
              Icons.fingerprint,
              'Muzzle Biometric',
              _muzzleVerified 
                  ? 'AI CONFIRMED${_muzzleId != null ? ' • $_muzzleId' : ''}'
                  : 'Tap to capture',
              _muzzleVerified,
              _muzzleVerified ? const Color(0xFFD3A15F) : Colors.grey,
              onTap: _muzzleVerified ? null : _startMuzzleCapture,
            ),
            const SizedBox(height: 12),
            _buildVerificationStep(Icons.image, 'Photo Quality Check', _photoQualityPassed ? 'PASSED' : 'PENDING', _photoQualityPassed, _photoQualityPassed ? Colors.green : Colors.grey),
            const SizedBox(height: 12),
            _buildVerificationStep(Icons.verified_user, 'Breed Verification', _breedVerified ? 'VERIFIED' : 'PENDING REVIEW', _breedVerified, _breedVerified ? Colors.green : Colors.grey, showTimer: !_breedVerified),
            const SizedBox(height: 12),
            _buildVerificationStep(Icons.badge, 'Seller Identity', _sellerVerified ? 'VERIFIED' : 'Action Required', _sellerVerified, _sellerVerified ? Colors.green : Colors.grey),
            
            const SizedBox(height: 24),
            
            // Preview Card
            const Text('Preview on Moomingle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            Text('How buyers see you', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=600'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  // Verified badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  // Info at bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bella, Jersey Cow', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF5D3A1A), borderRadius: BorderRadius.circular(10)),
                              child: const Text('Dairy', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF5D3A1A), borderRadius: BorderRadius.circular(10)),
                              child: const Text('4 Years', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                      ],
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
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              // Show document picker
              _showUploadOptions(context);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Breed Papers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD3A15F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showUploadOptions(BuildContext context) {
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
            const Text('Upload Breed Papers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Upload official breed certification documents', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.camera_alt, color: Colors.blue[700]),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture document with camera'),
              onTap: () {
                Navigator.pop(ctx);
                _simulateUpload(context, 'Photo captured');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.photo_library, color: Colors.green[700]),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () {
                Navigator.pop(ctx);
                _simulateUpload(context, 'Photo selected');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.picture_as_pdf, color: Colors.orange[700]),
              ),
              title: const Text('Upload PDF'),
              subtitle: const Text('Select PDF document'),
              onTap: () {
                Navigator.pop(ctx);
                _simulateUpload(context, 'PDF selected');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _simulateUpload(BuildContext context, String action) {
    // Show uploading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFD3A15F)),
            const SizedBox(height: 20),
            Text('Uploading document...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
    
    // Simulate upload delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Document uploaded! Under review.'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  Widget _buildVerificationStep(IconData icon, String title, String status, bool isComplete, Color color, {bool showTimer = false, VoidCallback? onTap}) {
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
                  Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (isComplete)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (showTimer)
              const Icon(Icons.hourglass_bottom, color: Colors.grey)
            else if (onTap != null)
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
            else
              Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!))),
          ],
        ),
      ),
    );
  }

  Future<void> _startMuzzleCapture() async {
    final result = await Navigator.push<MuzzleVerificationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MuzzleCaptureScreen(
          listingId: _listingId,
          animalName: widget.animalName,
          isVerification: false,
        ),
      ),
    );

    if (result != null && result.success && mounted) {
      setState(() {
        _muzzleVerified = true;
        _muzzleId = result.muzzleId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Muzzle verified! ID: ${result.muzzleId}'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
