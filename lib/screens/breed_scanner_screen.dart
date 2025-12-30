import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moomingle/services/breed_classifier_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class BreedScannerScreen extends StatefulWidget {
  const BreedScannerScreen({super.key});

  @override
  State<BreedScannerScreen> createState() => _BreedScannerScreenState();
}

class _BreedScannerScreenState extends State<BreedScannerScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  bool _showResult = false;
  bool _showCamera = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  String? _validationError;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera && _cameraController != null && _cameraController!.value.isInitialized) {
        setState(() => _showCamera = true);
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null && mounted) {
          final bytes = await image.readAsBytes();
          _scanBreed(bytes);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Fallback to gallery if camera fails
      if (!mounted) return;
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null && mounted) {
          final bytes = await image.readAsBytes();
          _scanBreed(bytes);
        }
      } catch (fallbackError) {
        debugPrint('Fallback image picker also failed: $fallbackError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to access camera or gallery. Please check permissions.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _captureFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      final XFile photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();
      setState(() => _showCamera = false);
      _scanBreed(bytes);
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _scanBreed(Uint8List imageBytes) async {
    setState(() {
      _isLoading = true;
      _validationError = null;
    });

    // Call API with real bytes
    final result = await BreedClassifierService.classifyBreed(imageBytes);
    
    // Validate if it's actually cattle/buffalo
    final confidence = (result['confidence'] as num).toDouble();
    final breed = result['breed'] as String;
    final isValidBreed = BreedClassifierService.isValidBreed(breed);
    
    // If confidence is too low or breed is unknown, it might not be cattle
    if (confidence < 0.5 || !isValidBreed) {
      setState(() {
        _isLoading = false;
        _validationError = 'Could not identify cattle/buffalo in this image.\n\nPlease ensure:\n• The animal is clearly visible\n• Good lighting conditions\n• The image shows a cattle or buffalo';
        _showResult = false;
        _result = null;
      });
      return;
    }
    
    setState(() {
      _isLoading = false;
      _result = result;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera && _cameraController != null && _cameraController!.value.isInitialized) {
      return _buildCameraView();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Breed Scanner', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Camera Preview Area
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD3A15F), width: 2),
              ),
              child: _validationError != null
                  ? _buildErrorCard()
                  : _showResult && _result != null
                      ? _buildResultCard()
                      : _buildCameraPlaceholder(),
            ),
            
            const SizedBox(height: 24),
            
            // Scan Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(_isLoading ? 'Analyzing...' : 'Scan Cattle/Buffalo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Gallery Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5D3A1A),
                  side: const BorderSide(color: Color(0xFFD3A15F)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text('Tips for best results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('• Capture the full body of the animal', style: TextStyle(fontSize: 12, color: Colors.blue[800])),
                  Text('• Ensure good lighting', style: TextStyle(fontSize: 12, color: Colors.blue[800])),
                  Text('• Keep the camera steady', style: TextStyle(fontSize: 12, color: Colors.blue[800])),
                  Text('• Avoid blurry images', style: TextStyle(fontSize: 12, color: Colors.blue[800])),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Supported Breeds Info
            const Text('Supported Breeds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 16),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildBreedList('🐃 Buffalo', BreedClassifierService.buffaloBreeds),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBreedList('🐄 Cattle', BreedClassifierService.cattleBreeds),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),
          
          // Visual Guide Overlay
          CustomPaint(
            painter: CameraGuidePainter(),
            child: Container(),
          ),
          
          // Guide Text
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    'Position the cattle/buffalo',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Align the full body within the frame',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Capture indicators
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCaptureHint(Icons.wb_sunny, 'Good Light'),
                const SizedBox(width: 20),
                _buildCaptureHint(Icons.center_focus_strong, 'Full Body'),
                const SizedBox(width: 20),
                _buildCaptureHint(Icons.motion_photos_off, 'Stay Still'),
              ],
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel
                IconButton(
                  onPressed: () => setState(() => _showCamera = false),
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                ),
                // Capture
                GestureDetector(
                  onTap: _captureFromCamera,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Gallery
                IconButton(
                  onPressed: () {
                    setState(() => _showCamera = false);
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureHint(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 60, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Point camera at cattle or buffalo', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text('AI will identify the breed', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Not Recognized', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 8),
          Text(
            _validationError ?? 'Could not identify the animal',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() {
              _validationError = null;
              _showResult = false;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final breed = _result!['breed'] as String;
    final confidence = (_result!['confidence'] as num) * 100;
    final animalType = _result!['animal_type'] as String;
    final allScores = _result!['all_scores'] as Map<String, dynamic>;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Result
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(animalType == 'Buffalo' ? '🐃' : '🐄', style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(breed, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                  Text(animalType, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Confidence Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text('${confidence.toStringAsFixed(0)}% Confidence', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Top 3 Matches
          Expanded(
            child: ListView(
              children: allScores.entries
                  .toList()
                  .take(3)
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12))),
                            SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: (e.value as num).toDouble(),
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(e.key == breed ? Colors.green : Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${((e.value as num) * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedList(String title, List<String> breeds) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 8),
          ...breeds.take(5).map((b) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('• $b', style: const TextStyle(fontSize: 12, color: Color(0xFF5D3A1A))),
          )),
          if (breeds.length > 5)
            Text('+ ${breeds.length - 5} more', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

/// Custom painter for camera guide overlay
class CameraGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Draw cattle silhouette guide
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final guideWidth = size.width * 0.75;
    final guideHeight = size.height * 0.4;
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: guideWidth, height: guideHeight),
      const Radius.circular(20),
    );
    
    canvas.drawRRect(rect, paint);
    
    // Corner brackets
    final bracketPaint = Paint()
      ..color = const Color(0xFFD3A15F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final bracketLength = 30.0;
    final left = centerX - guideWidth / 2;
    final right = centerX + guideWidth / 2;
    final top = centerY - guideHeight / 2;
    final bottom = centerY + guideHeight / 2;
    
    // Top-left
    canvas.drawLine(Offset(left, top + bracketLength), Offset(left, top), bracketPaint);
    canvas.drawLine(Offset(left, top), Offset(left + bracketLength, top), bracketPaint);
    
    // Top-right
    canvas.drawLine(Offset(right - bracketLength, top), Offset(right, top), bracketPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + bracketLength), bracketPaint);
    
    // Bottom-left
    canvas.drawLine(Offset(left, bottom - bracketLength), Offset(left, bottom), bracketPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + bracketLength, bottom), bracketPaint);
    
    // Bottom-right
    canvas.drawLine(Offset(right - bracketLength, bottom), Offset(right, bottom), bracketPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - bracketLength), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
