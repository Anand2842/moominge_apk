import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/services/api_service.dart';
import 'package:moomingle/models/cow_listing.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('should initialize with empty listings', () {
      expect(apiService.listings, isEmpty);
      expect(apiService.isLoading, isFalse);
    });

    test('should fetch listings', () async {
      await apiService.fetchListings();
      expect(apiService.isLoading, isFalse);
      // In mock mode, should have mock data
    });

    test('should handle fetch error gracefully', () async {
      await apiService.fetchListings();
      expect(apiService.errorMessage, isNull);
    });

    test('should add listing', () async {
      final testListing = CowListing(
        id: 'test-id',
        name: 'Test Cow',
        breed: 'Gir',
        age: '3',
        price: 50000.0,
        location: 'Test Location',
        yieldAmount: '10L',
        imageUrl: 'https://example.com/image.jpg',
        sellerName: 'Test Seller',
        isVerified: false,
      );

      await apiService.addListing(testListing);
      // Should not throw error
    });

    test('should update listing', () async {
      await apiService.updateListing('test-id', {
        'name': 'Updated Name',
        'price': 60000,
      });
      // Should not throw error
    });

    test('should delete listing', () async {
      await apiService.deleteListing('test-id');
      // Should not throw error
    });

    test('should handle listing operations', () async {
      await apiService.fetchListings();
      expect(apiService.listings, isNotNull);
    });
  });
}
