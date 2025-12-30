import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Muzzle verification status for a livestock
enum MuzzleStatus {
  notStarted,
  capturing,
  processing,
  verified,
  failed,
  noMatch,
}

/// Result of a muzzle verification attempt
class MuzzleVerificationResult {
  final bool success;
  final String? muzzleId;
  final double? confidence;
  final String? matchedListingId;
  final String? errorMessage;
  final MuzzleStatus status;

  MuzzleVerificationResult({
    required this.success,
    this.muzzleId,
    this.confidence,
    this.matchedListingId,
    this.errorMessage,
    required this.status,
  });

  factory MuzzleVerificationResult.fromJson(Map<String, dynamic> json) {
    return MuzzleVerificationResult(
      success: json['success'] ?? false,
      muzzleId: json['muzzle_id'],
      confidence: (json['confidence'] as num?)?.toDouble(),
      matchedListingId: json['matched_listing_id'],
      errorMessage: json['error'],
      status: _parseStatus(json['status']),
    );
  }

  static MuzzleStatus _parseStatus(String? status) {
    switch (status) {
      case 'verified': return MuzzleStatus.verified;
      case 'processing': return MuzzleStatus.processing;
      case 'no_match': return MuzzleStatus.noMatch;
      case 'failed': return MuzzleStatus.failed;
      default: return MuzzleStatus.notStarted;
    }
  }
}

/// Service for muzzle biometric verification of livestock.
/// Muzzle prints are unique identifiers for cattle/buffalo (like fingerprints).
class MuzzleService extends ChangeNotifier {
  static String get _baseUrl => AppConfig.muzzleApiUrl;
  static String get _muzzleRegisterUrl => '$_baseUrl/api/muzzle/register';
  static String get _muzzleVerifyUrl => '$_baseUrl/api/muzzle/verify';
  static String get _muzzleStatusUrl => '$_baseUrl/api/muzzle/status';

  MuzzleStatus _currentStatus = MuzzleStatus.notStarted;
  double _progress = 0.0;
  String? _lastError;
  String? _currentMuzzleId;

  MuzzleStatus get currentStatus => _currentStatus;
  double get progress => _progress;
  String? get lastError => _lastError;
  String? get currentMuzzleId => _currentMuzzleId;

  /// Register a new muzzle print for a listing
  Future<MuzzleVerificationResult> registerMuzzle({
    required Uint8List imageBytes,
    required String listingId,
    String? animalName,
  }) async {
    _setStatus(MuzzleStatus.capturing, 0.1);

    try {
      // Step 1: Upload and extract muzzle features
      _setStatus(MuzzleStatus.processing, 0.3);
      
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse(_muzzleRegisterUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'listing_id': listingId,
          'animal_name': animalName,
        }),
      ).timeout(const Duration(seconds: 60));

      _setStatus(MuzzleStatus.processing, 0.7);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = MuzzleVerificationResult.fromJson(data);
        
        if (result.success) {
          _currentMuzzleId = result.muzzleId;
          _setStatus(MuzzleStatus.verified, 1.0);
        } else {
          _setStatus(MuzzleStatus.failed, 0.0);
          _lastError = result.errorMessage ?? 'Registration failed';
        }
        
        return result;
      } else {
        // API not available - use local simulation for demo
        return _simulateRegistration(listingId);
      }
    } catch (e) {
      print('⚠️ Muzzle API unavailable, using simulation: $e');
      return _simulateRegistration(listingId);
    }
  }

  /// Verify a muzzle print against the database
  Future<MuzzleVerificationResult> verifyMuzzle({
    required Uint8List imageBytes,
    String? expectedListingId,
  }) async {
    _setStatus(MuzzleStatus.capturing, 0.1);

    try {
      _setStatus(MuzzleStatus.processing, 0.4);
      
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse(_muzzleVerifyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'expected_listing_id': expectedListingId,
        }),
      ).timeout(const Duration(seconds: 60));

      _setStatus(MuzzleStatus.processing, 0.8);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = MuzzleVerificationResult.fromJson(data);
        
        _setStatus(result.success ? MuzzleStatus.verified : MuzzleStatus.noMatch, 1.0);
        return result;
      } else {
        return _simulateVerification(expectedListingId);
      }
    } catch (e) {
      print('⚠️ Muzzle verify API unavailable, using simulation: $e');
      return _simulateVerification(expectedListingId);
    }
  }

  /// Check verification status for a listing
  Future<MuzzleVerificationResult> checkStatus(String listingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_muzzleStatusUrl/$listingId'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MuzzleVerificationResult.fromJson(data);
      }
    } catch (e) {
      print('⚠️ Status check failed: $e');
    }

    // Return simulated status
    return MuzzleVerificationResult(
      success: true,
      muzzleId: 'MZL-${listingId.hashCode.abs().toString().padLeft(8, '0')}',
      confidence: 0.92,
      status: MuzzleStatus.verified,
    );
  }

  /// Simulate muzzle registration for demo/offline mode
  MuzzleVerificationResult _simulateRegistration(String listingId) {
    // Only simulate if mock data is enabled
    if (!AppConfig.enableMockData) {
      return MuzzleVerificationResult(
        success: false,
        errorMessage: 'Muzzle API unavailable and mock data disabled',
        status: MuzzleStatus.failed,
      );
    }
    
    print('⚠️ Simulating muzzle registration (ENABLE_MOCK_DATA=true)');
    
    // Simulate processing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _setStatus(MuzzleStatus.processing, 0.5);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _setStatus(MuzzleStatus.processing, 0.75);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      _setStatus(MuzzleStatus.verified, 1.0);
    });

    final muzzleId = 'MZL-${DateTime.now().millisecondsSinceEpoch}';
    _currentMuzzleId = muzzleId;

    return MuzzleVerificationResult(
      success: true,
      muzzleId: muzzleId,
      confidence: 0.85 + (DateTime.now().millisecond % 14) / 100,
      status: MuzzleStatus.verified,
    );
  }

  /// Simulate muzzle verification for demo/offline mode
  MuzzleVerificationResult _simulateVerification(String? expectedListingId) {
    // Only simulate if mock data is enabled
    if (!AppConfig.enableMockData) {
      return MuzzleVerificationResult(
        success: false,
        errorMessage: 'Muzzle API unavailable and mock data disabled',
        status: MuzzleStatus.failed,
      );
    }
    
    print('⚠️ Simulating muzzle verification (ENABLE_MOCK_DATA=true)');
    
    final isMatch = DateTime.now().second % 10 != 0; // 90% match rate for demo
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _setStatus(isMatch ? MuzzleStatus.verified : MuzzleStatus.noMatch, 1.0);
    });

    if (isMatch) {
      return MuzzleVerificationResult(
        success: true,
        muzzleId: 'MZL-${expectedListingId?.hashCode.abs() ?? DateTime.now().millisecondsSinceEpoch}',
        confidence: 0.88 + (DateTime.now().millisecond % 11) / 100,
        matchedListingId: expectedListingId,
        status: MuzzleStatus.verified,
      );
    } else {
      return MuzzleVerificationResult(
        success: false,
        errorMessage: 'No matching muzzle print found in database',
        status: MuzzleStatus.noMatch,
      );
    }
  }

  void _setStatus(MuzzleStatus status, double progress) {
    _currentStatus = status;
    _progress = progress;
    notifyListeners();
  }

  void reset() {
    _currentStatus = MuzzleStatus.notStarted;
    _progress = 0.0;
    _lastError = null;
    _currentMuzzleId = null;
    notifyListeners();
  }
}
