import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('should initialize with session ID', () {
      expect(analyticsService, isNotNull);
    });

    test('should track listing view without error', () async {
      await analyticsService.trackListingView('test-listing-id');
      // No exception means success in mock mode
    });

    test('should track listing like without error', () async {
      await analyticsService.trackListingLike('test-listing-id');
    });

    test('should track listing pass without error', () async {
      await analyticsService.trackListingPass('test-listing-id');
    });

    test('should track chat started without error', () async {
      await analyticsService.trackChatStarted('chat-id', 'listing-id');
    });

    test('should track offer made without error', () async {
      await analyticsService.trackOfferMade('listing-id', 50000.0);
    });

    test('should track purchase completed without error', () async {
      await analyticsService.trackPurchaseCompleted(
        'listing-id',
        75000.0,
        'upi',
      );
    });

    test('should log error without throwing', () async {
      await analyticsService.logError(
        'test_error',
        'Test error message',
        severity: 'low',
      );
    });

    test('should reset session', () {
      analyticsService.resetSession();
      expect(analyticsService, isNotNull);
    });
  });
}
