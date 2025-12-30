import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Analytics service for tracking user behavior and app performance
/// Provides monitoring capabilities for business metrics
class AnalyticsService extends ChangeNotifier {
  String? _sessionId;
  Map<String, dynamic>? _deviceInfo;

  AnalyticsService() {
    _initSession();
  }

  void _initSession() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _deviceInfo = {
      'platform': defaultTargetPlatform.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Track a listing view
  Future<void> trackListingView(String listingId) async {
    await _trackEvent('listing_view', {'listing_id': listingId});
  }

  /// Track a listing like
  Future<void> trackListingLike(String listingId) async {
    await _trackEvent('listing_like', {'listing_id': listingId});
  }

  /// Track a listing pass
  Future<void> trackListingPass(String listingId) async {
    await _trackEvent('listing_pass', {'listing_id': listingId});
  }

  /// Track a listing share
  Future<void> trackListingShare(String listingId, String method) async {
    await _trackEvent('listing_share', {
      'listing_id': listingId,
      'share_method': method,
    });
  }

  /// Track chat started
  Future<void> trackChatStarted(String chatId, String listingId) async {
    await _trackEvent('chat_started', {
      'chat_id': chatId,
      'listing_id': listingId,
    });
  }

  /// Track message sent
  Future<void> trackMessageSent(String chatId) async {
    await _trackEvent('message_sent', {'chat_id': chatId});
  }

  /// Track offer made
  Future<void> trackOfferMade(String listingId, double amount) async {
    await _trackEvent('offer_made', {
      'listing_id': listingId,
      'offer_amount': amount,
    });
  }

  /// Track purchase completed
  Future<void> trackPurchaseCompleted(
    String listingId,
    double amount,
    String paymentMethod,
  ) async {
    await _trackEvent('purchase_completed', {
      'listing_id': listingId,
      'purchase_amount': amount,
      'payment_method': paymentMethod,
    });
  }

  /// Track profile view
  Future<void> trackProfileView(String profileId) async {
    await _trackEvent('profile_view', {'profile_id': profileId});
  }

  /// Track search performed
  Future<void> trackSearch(String query, int resultsCount) async {
    await _trackEvent('search_performed', {
      'query': query,
      'results_count': resultsCount,
    });
  }

  /// Track filter applied
  Future<void> trackFilterApplied(Map<String, dynamic> filters) async {
    await _trackEvent('filter_applied', {'filters': filters});
  }

  /// Track breed scan
  Future<void> trackBreedScan(String? detectedBreed, double? confidence) async {
    await _trackEvent('breed_scan', {
      'detected_breed': detectedBreed,
      'confidence': confidence,
    });
  }

  /// Track muzzle capture
  Future<void> trackMuzzleCapture(String listingId, bool success) async {
    await _trackEvent('muzzle_capture', {
      'listing_id': listingId,
      'success': success,
    });
  }

  /// Track boost purchased
  Future<void> trackBoostPurchased(String listingId, int duration) async {
    await _trackEvent('boost_purchased', {
      'listing_id': listingId,
      'duration_days': duration,
    });
  }

  /// Log an error for monitoring
  Future<void> logError(
    String errorType,
    String errorMessage, {
    String? stackTrace,
    Map<String, dynamic>? context,
    String severity = 'medium',
  }) async {
    if (!SupabaseService.isInitialized) return;

    try {
      final user = SupabaseService.client.auth.currentUser;
      
      await SupabaseService.client.from('error_logs').insert({
        'user_id': user?.id,
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace,
        'context': context,
        'severity': severity,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Failed to log error: $e');
    }
  }

  /// Get user engagement metrics
  Future<Map<String, dynamic>?> getUserEngagement() async {
    if (!SupabaseService.isInitialized) return null;

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return null;

      final response = await SupabaseService.client
          .rpc('get_user_engagement', params: {'p_user_id': user.id});

      if (response != null && response.isNotEmpty) {
        return response[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get user engagement: $e');
      return null;
    }
  }

  /// Get daily active users (admin only)
  Future<List<Map<String, dynamic>>> getDailyActiveUsers({int days = 30}) async {
    if (!SupabaseService.isInitialized) return [];

    try {
      final response = await SupabaseService.client
          .from('daily_active_users')
          .select()
          .limit(days);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Failed to get daily active users: $e');
      return [];
    }
  }

  /// Get popular listings
  Future<List<Map<String, dynamic>>> getPopularListings({int limit = 10}) async {
    if (!SupabaseService.isInitialized) return [];

    try {
      final response = await SupabaseService.client
          .from('popular_listings')
          .select()
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Failed to get popular listings: $e');
      return [];
    }
  }

  /// Get seller performance metrics
  Future<Map<String, dynamic>?> getSellerPerformance(String sellerId) async {
    if (!SupabaseService.isInitialized) return null;

    try {
      final response = await SupabaseService.client
          .from('seller_performance')
          .select()
          .eq('seller_id', sellerId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Failed to get seller performance: $e');
      return null;
    }
  }

  /// Private method to track events
  Future<void> _trackEvent(String eventType, Map<String, dynamic> eventData) async {
    if (!SupabaseService.isInitialized) return;

    try {
      final user = SupabaseService.client.auth.currentUser;
      
      await SupabaseService.client.from('analytics_events').insert({
        'user_id': user?.id,
        'event_type': eventType,
        'event_data': eventData,
        'session_id': _sessionId,
        'device_info': _deviceInfo,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Failed to track event $eventType: $e');
    }
  }

  /// Reset session (call on app restart or logout)
  void resetSession() {
    _initSession();
    notifyListeners();
  }
}
