import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:moomingle/services/breed_classifier_service.dart';
import 'package:moomingle/screens/add_details_screen.dart';

class AiInspectionScreen extends StatefulWidget {
  final Uint8List? imageBytes;

  const AiInspectionScreen({super.key, this.imageBytes});

  @override
  State<AiInspectionScreen> createState() => _AiInspectionScreenState();
}

class _AiInspectionScreenState extends State<AiInspectionScreen> {
  // Simulator Image (Matches AddCattleScreen)
  static const String _imageUrl = 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=600';
  
  bool _loading = true;
  String _detectedBreed = 'Analyzing...';
  double _confidence = 0.0;
  bool _isVerified = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    try {
      Uint8List bytes;
      
      if (widget.imageBytes != null) {
        bytes = widget.imageBytes!;
      } else {
        // 1. Fetch Image Bytes (Simulating Capture fallback)
        final response = await http.get(Uri.parse(_imageUrl));
        bytes = response.bodyBytes;
      }

      // 2. Call Breed Classifier
      final result = await BreedClassifierService.classifyBreed(bytes);

      if (mounted) {
        setState(() {
          _detectedBreed = result['breed'];
          _confidence = result['confidence'];
          // Enforce 80% Threshold
          _isVerified = _confidence >= 0.8;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Analysis Failed';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5E0C3),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF3E2723)),
              SizedBox(height: 16),
              Text('AI Identifying Breed...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('AI Inspection Results', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner (Success/Fail)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _isVerified ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isVerified ? Colors.green : Colors.red),
              ),
              child: Row(
                children: [
                   Icon(
                    _isVerified ? Icons.check_circle : Icons.error, 
                    color: _isVerified ? Colors.green[800] : Colors.red[800],
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isVerified ? 'VERIFICATION PASSED' : 'VERIFICATION FAILED',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: _isVerified ? Colors.green[900] : Colors.red[900]
                          ),
                        ),
                        Text(
                          _isVerified 
                            ? 'High confidence match found.' 
                            : 'Accuracy is below 80%. Please retake photo.',
                          style: TextStyle(
                            color: _isVerified ? Colors.green[700] : Colors.red[700],
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: widget.imageBytes != null 
                ? Image.memory(widget.imageBytes!, height: 220, width: double.infinity, fit: BoxFit.cover)
                : Image.network(_imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover),
            ),
            
            const SizedBox(height: 24),
            
            // Result Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70, height: 70,
                        child: CircularProgressIndicator(
                          value: _confidence,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            _isVerified ? const Color(0xFFD3A15F) : Colors.red,
                          ),
                        ),
                      ),
                      Text('${(_confidence * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DETECTED BREED', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        _detectedBreed, 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: _isVerified ? () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddDetailsScreen(initialBreed: _detectedBreed)));
            } : () {
              Navigator.pop(context); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isVerified ? const Color(0xFF3E2723) : Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              _isVerified ? 'Confirm & Continue' : 'Retake Photo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
