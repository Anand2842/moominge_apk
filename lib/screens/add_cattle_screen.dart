import 'package:flutter/material.dart';
import 'package:moomingle/screens/ai_inspection_screen.dart';
import 'package:moomingle/services/breed_classifier_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../config/app_config.dart';

class AddCattleScreen extends StatefulWidget {
  const AddCattleScreen({super.key});

  @override
  State<AddCattleScreen> createState() => _AddCattleScreenState();
}

class _AddCattleScreenState extends State<AddCattleScreen> {
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    // Pre-warm the Render API while user captures photos
    BreedClassifierService.warmUp();
  }
  final List<String> _steps = ['LEFT SIDE', 'RIGHT SIDE', 'FRONT', 'BACK', 'UDDER', 'LEGS', 'FACE', 'MUZZLE'];
  final List<IconData> _stepIcons = [
    Icons.arrow_back, Icons.arrow_forward, Icons.crop_square, Icons.flip_to_back,
    Icons.water_drop, Icons.directions_walk, Icons.face, Icons.fingerprint
  ];

  final ImagePicker _picker = ImagePicker();
  Uint8List? _lastCapturedImage;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  void _toggleFlash() {
    setState(() => _isFlashOn = !_isFlashOn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFlashOn ? 'Flash ON' : 'Flash OFF'),
        duration: const Duration(milliseconds: 500),
        backgroundColor: const Color(0xFF5D3A1A),
      ),
    );
  }

  void _toggleCamera() {
    setState(() => _isFrontCamera = !_isFrontCamera);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFrontCamera ? 'Front camera' : 'Back camera'),
        duration: const Duration(milliseconds: 500),
        backgroundColor: const Color(0xFF5D3A1A),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: _isFrontCamera ? CameraDevice.front : CameraDevice.rear,
      );
      
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _lastCapturedImage = bytes;
        });

        if (_currentStep < _steps.length - 1) {
          setState(() => _currentStep++);
        } else {
          // All photos captured, go to AI inspection
          if (!mounted) return;
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => AiInspectionScreen(imageBytes: _lastCapturedImage)
          ));
        }
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview (simulated with image)
          Positioned.fill(
            child: _lastCapturedImage != null 
              ? Image.memory(_lastCapturedImage!, fit: BoxFit.cover)
              : Image.network(
                  AppConfig.placeholderImageUrl,
                  fit: BoxFit.cover,
                ),
          ),
          
          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const Text('Add New Cattle', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: _isFlashOn ? Colors.yellow : Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Move Closer Warning
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Move closer to subject', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          
          // Alignment Guide (Center)
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD3A15F), width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner brackets
                  Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                  Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
                  // Center cross
                  const Center(child: Icon(Icons.add, color: Colors.white54, size: 40)),
                ],
              ),
            ),
          ),
          
          // Instruction Text
          Positioned(
            bottom: 280,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(_steps[_currentStep].replaceAll('_', ' ') + ' View', 
                     style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Align cow with the outline', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          
          // Bottom Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF5E0C3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PROGRESS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text('STEP ${_currentStep + 1} OF ${_steps.length}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Step Indicators
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _steps.length,
                      itemBuilder: (context, index) {
                        bool isActive = index == _currentStep;
                        bool isCompleted = index < _currentStep;
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFFD3A15F) : (isCompleted ? Colors.green : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isActive ? const Color(0xFFD3A15F) : Colors.grey.shade300),
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : _stepIcons[index],
                                  color: isActive || isCompleted ? Colors.white : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(_steps[index], style: TextStyle(fontSize: 8, color: isActive ? const Color(0xFF3E2723) : Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (index) => Container(
                      width: index == _currentStep ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? const Color(0xFFD3A15F) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Camera Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(AppConfig.placeholderImageUrl),
                      ),
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3A15F),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleCamera,
                        icon: const Icon(Icons.flip_camera_ios, color: Color(0xFF5D3A1A), size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFFD3A15F), width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFFD3A15F), width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFFD3A15F), width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFFD3A15F), width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
