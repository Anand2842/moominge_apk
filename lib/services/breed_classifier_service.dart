import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Service to classify cattle/buffalo breed using the Render API.
class BreedClassifierService {
  // API URLs from config
  static String get _baseUrl => AppConfig.breedApiUrl;
  static String get _predictUrl => '$_baseUrl/api/predict';
  static String get _predictBase64Url => '$_baseUrl/api/predict/base64';
  static String get _healthUrl => '$_baseUrl/api/health';

  /// Classifies the breed from image bytes.
  /// Wakes up the Render service first if needed, then classifies.
  static Future<Map<String, dynamic>> classifyBreed(Uint8List imageBytes) async {
    // First, wake up the service by hitting health endpoint
    final isAwake = await _wakeUpService();
    
    if (isAwake) {
      // Try base64 endpoint (more reliable for Render)
      try {
        print('🌐 Calling Render Breed Classification API (base64)...');
        final result = await _callRenderApiBase64(imageBytes);
        if (result != null) return result;
      } catch (e) {
        print('⚠️ Render base64 API failed: $e');
      }
      
      // Fallback to multipart upload
      try {
        print('🌐 Trying multipart upload...');
        final result = await _callRenderApiMultipart(imageBytes);
        if (result != null) return result;
      } catch (e) {
        print('⚠️ Render multipart API failed: $e');
      }
    }
    
    // Fallback to mock with low confidence to indicate uncertainty
    print('⚠️ Using fallback classification');
    return _getMockResult(lowConfidence: true);
  }
  
  /// Wake up the Render service by hitting the health endpoint
  /// Can be called early to pre-warm the API before classification is needed
  static Future<bool> warmUp() async => _wakeUpService();
  
  static Future<bool> _wakeUpService() async {
    print('🔄 Waking up Render service...');
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(_healthUrl),
        ).timeout(Duration(seconds: 30 * attempt));
        
        if (response.statusCode == 200) {
          print('✅ Service is awake!');
          return true;
        }
      } catch (e) {
        print('⏳ Wake-up attempt $attempt failed: $e');
        if (attempt < 3) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    print('⚠️ Could not wake up service');
    return false;
  }
  
  /// Call the Render API with base64 encoded image
  static Future<Map<String, dynamic>?> _callRenderApiBase64(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse(_predictBase64Url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(const Duration(seconds: 120));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Render API Response: $data');
        return _parseApiResponse(data);
      } else {
        print('⚠️ Render base64 API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Render base64 API Exception: $e');
      return null;
    }
  }
  
  /// Call the Render API with multipart file upload
  static Future<Map<String, dynamic>?> _callRenderApiMultipart(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_predictUrl));
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: 'upload.jpg')
      );
      
      var response = await request.send().timeout(const Duration(seconds: 120));
      
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        print('✅ Render API Response: $data');
        return _parseApiResponse(data);
      } else {
        print('⚠️ Render multipart API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Render multipart API Exception: $e');
      return null;
    }
  }
  
  /// Parse API response into standard format
  static Map<String, dynamic> _parseApiResponse(Map<String, dynamic> data) {
    final breed = data['breed'] ?? 'Unknown';
    final confidence = (data['confidence'] ?? 0.5).toDouble();
    
    return {
      'breed': breed,
      'confidence': confidence,
      'animal_type': data['animal_type'] ?? _getAnimalType(breed),
      'is_verified': data['is_verified'] ?? confidence >= 0.8,
      'all_scores': data['all_scores'] ?? _generateScores(breed, confidence),
    };
  }
  
  /// Generate mock scores for display
  static Map<String, dynamic> _generateScores(String topBreed, double topConfidence) {
    final scores = <String, dynamic>{};
    scores[topBreed] = topConfidence;
    
    // Add some other breeds with lower scores
    final otherBreeds = allBreeds.where((b) => b != topBreed).take(4);
    double remaining = 1.0 - topConfidence;
    for (final breed in otherBreeds) {
      final score = remaining * 0.2;
      scores[breed] = score;
      remaining -= score;
    }
    
    return scores;
  }
  
  /// Determine animal type from breed name
  static String _getAnimalType(String breed) {
    if (buffaloBreeds.contains(breed)) return 'Buffalo';
    if (cattleBreeds.contains(breed)) return 'Cattle';
    return 'Unknown';
  }

  /// Mock result for demo/fallback purposes
  static Map<String, dynamic> _getMockResult({bool lowConfidence = false}) {
    // Only return mock data if feature flag is enabled
    if (!AppConfig.enableMockData) {
      throw Exception('API unavailable and mock data disabled');
    }
    
    print('⚠️ Returning mock breed classification (ENABLE_MOCK_DATA=true)');
    
    final isBuffalo = DateTime.now().second % 2 == 0;
    final list = isBuffalo ? buffaloBreeds : cattleBreeds;
    final breed = list[DateTime.now().microsecond % list.length];
    
    // If lowConfidence flag is set, return lower confidence to indicate uncertainty
    final confidence = lowConfidence 
        ? 0.45 + (DateTime.now().millisecond % 20) / 100  // 0.45-0.65
        : 0.85 + (DateTime.now().millisecond % 14) / 100; // 0.85-0.99
    
    return {
      'breed': breed,
      'confidence': confidence,
      'animal_type': isBuffalo ? 'Buffalo' : 'Cattle',
      'is_verified': confidence >= 0.8,
      'all_scores': _generateScores(breed, confidence),
    };
  }

  /// List of supported breeds (50 total)
  static const List<String> buffaloBreeds = [
    'Murrah', 'Jaffarbadi', 'Mehsana', 'Bhadawari', 'Surti',
    'Nili-Ravi', 'Pandharpuri', 'Nagpuri', 'Toda', 'Chilika',
  ];
  
  static const List<String> cattleBreeds = [
    'Gir', 'Kankrej', 'Ongole', 'Sahiwal', 'Tharparkar',
    'Red Sindhi', 'Rathi', 'Hariana', 'Deoni', 'Hallikar',
    'Amritmahal', 'Khillari', 'Kangayam', 'Bargur', 'Punganur',
    'Vechur', 'Kasaragod', 'Malnad Gidda', 'Krishna Valley', 'Dangi',
    'Gaolao', 'Nimari', 'Kenkatha', 'Ponwar', 'Bachaur',
    'Siri', 'Mewati', 'Nagori', 'Malvi', 'Kherigarh',
    'Gangatiri', 'Belahi', 'Lohani', 'Rojhan', 'Dajal',
    'Bhagnari', 'Dhanni', 'Cholistani', 'Achai', 'Lakhani',
  ];
  
  /// All supported breeds
  static List<String> get allBreeds => [...buffaloBreeds, ...cattleBreeds];
  
  /// Check if a breed is valid
  static bool isValidBreed(String breed) {
    return allBreeds.contains(breed);
  }
}
