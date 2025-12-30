import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/muzzle_service.dart';

/// Screen for capturing muzzle biometric images for livestock verification.
class MuzzleCaptureScreen extends StatefulWidget {
  final String listingId;
  final String? animalName;
  final bool isVerification; // true = verify existing, false = register new

  const MuzzleCaptureScreen({
    super.key,
    required this.listingId,
    this.animalName,
    this.isVerification = false,
  });

  @override
  State<MuzzleCaptureScreen> createState() => _MuzzleCaptureScreenState();
}

class _MuzzleCaptureScreenState extends State<MuzzleCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _capturedImage;
  bool _isProcessing = false;
  MuzzleVerificationResult? _result;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MuzzleService(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E0C3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Color(0xFF5D3A1A)),
          title: Text(
            widget.isVerification ? 'Verify Muzzle' : 'Register Muzzle',
            style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Consumer<MuzzleService>(
          builder: (context, muzzleService, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Instructions Card
                  _buildInstructionsCard(),
                  const SizedBox(height: 24),

                  // Capture Area
                  _buildCaptureArea(muzzleService),
                  const SizedBox(height: 24),

                  // Progress/Status
                  if (_isProcessing || muzzleService.currentStatus != MuzzleStatus.notStarted)
                    _buildProgressCard(muzzleService),

                  // Result
                  if (_result != null) ...[
                    const SizedBox(height: 24),
                    _buildResultCard(),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(muzzleService),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3A15F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFFD3A15F)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Muzzle Biometric Capture',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cattle muzzle prints are unique like human fingerprints. '
            'Capture a clear photo of the nose/muzzle area for verification.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildTipRow(Icons.wb_sunny, 'Good lighting on the muzzle'),
          _buildTipRow(Icons.center_focus_strong, 'Focus on nose ridges'),
          _buildTipRow(Icons.straighten, 'Keep camera 30-50cm away'),
          _buildTipRow(Icons.cleaning_services, 'Clean muzzle if dirty'),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCaptureArea(MuzzleService muzzleService) {
    return GestureDetector(
      onTap: _capturedImage == null ? _showCaptureOptions : null,
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _capturedImage != null ? const Color(0xFFD3A15F) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: _capturedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_capturedImage!, fit: BoxFit.cover),
                    // Muzzle overlay guide
                    Center(
                      child: Container(
                        width: 150,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          borderRadius: BorderRadius.circular(75),
                        ),
                      ),
                    ),
                    // Retake button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => setState(() {
                          _capturedImage = null;
                          _result = null;
                        }),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3A15F).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 60,
                      color: Color(0xFFD3A15F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to capture muzzle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use camera or select from gallery',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressCard(MuzzleService muzzleService) {
    final status = muzzleService.currentStatus;
    final progress = muzzleService.progress;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case MuzzleStatus.capturing:
        statusText = 'Capturing image...';
        statusColor = Colors.blue;
        statusIcon = Icons.camera_alt;
        break;
      case MuzzleStatus.processing:
        statusText = 'Analyzing muzzle pattern...';
        statusColor = Colors.orange;
        statusIcon = Icons.psychology;
        break;
      case MuzzleStatus.verified:
        statusText = 'Muzzle verified!';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case MuzzleStatus.noMatch:
        statusText = 'No match found';
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case MuzzleStatus.failed:
        statusText = 'Verification failed';
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusText = 'Ready';
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result!;
    final isSuccess = result.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.verified : Icons.error,
            size: 48,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          Text(
            isSuccess
                ? (widget.isVerification ? 'Identity Confirmed!' : 'Muzzle Registered!')
                : 'Verification Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          if (result.muzzleId != null) ...[
            const SizedBox(height: 8),
            Text(
              'ID: ${result.muzzleId}',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey.shade700,
              ),
            ),
          ],
          if (result.confidence != null) ...[
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
          if (result.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              result.errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(MuzzleService muzzleService) {
    if (_result?.success == true) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, _result),
          icon: const Icon(Icons.check),
          label: const Text('Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ),
      );
    }

    if (_capturedImage == null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _showCaptureOptions,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture Muzzle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD3A15F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _processImage(muzzleService),
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.fingerprint),
        label: Text(
          _isProcessing
              ? 'Processing...'
              : (widget.isVerification ? 'Verify Identity' : 'Register Muzzle'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3E2723),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }

  void _showCaptureOptions() {
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
            const Text(
              'Capture Muzzle Image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take a clear photo of the animal\'s nose/muzzle',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Use camera to capture muzzle'),
              onTap: () {
                Navigator.pop(ctx);
                _captureImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library, color: Colors.green.shade700),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing muzzle photo'),
              onTap: () {
                Navigator.pop(ctx);
                _captureImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _capturedImage = bytes;
          _result = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  Future<void> _processImage(MuzzleService muzzleService) async {
    if (_capturedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      MuzzleVerificationResult result;

      if (widget.isVerification) {
        result = await muzzleService.verifyMuzzle(
          imageBytes: _capturedImage!,
          expectedListingId: widget.listingId,
        );
      } else {
        result = await muzzleService.registerMuzzle(
          imageBytes: _capturedImage!,
          listingId: widget.listingId,
          animalName: widget.animalName,
        );
      }

      setState(() => _result = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
