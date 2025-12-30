import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/models/cow_listing.dart';

void main() {
  group('CowListing', () {
    test('should create from JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Cow',
        'breed': 'Gir',
        'age': '3',
        'price': 50000,
        'location': 'Gujarat',
        'yield_amount': '10L',
        'image_url': 'https://example.com/image.jpg',
        'seller_name': 'Test Seller',
        'is_verified': true,
      };

      final listing = CowListing.fromJson(json);

      expect(listing.id, equals('test-id'));
      expect(listing.name, equals('Test Cow'));
      expect(listing.breed, equals('Gir'));
      expect(listing.age, equals('3'));
      expect(listing.price, equals(50000.0));
      expect(listing.location, equals('Gujarat'));
      expect(listing.isVerified, isTrue);
    });

    test('should handle missing optional fields', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Cow',
        'breed': 'Gir',
        'age': '3',
        'price': 50000,
        'location': 'Gujarat',
        'yield_amount': '10L',
        'image_url': 'https://example.com/image.jpg',
      };

      final listing = CowListing.fromJson(json);

      expect(listing.sellerName, isNull);
      expect(listing.animalType, isNull);
    });

    test('should handle default values', () {
      final json = {};

      final listing = CowListing.fromJson(json);

      expect(listing.id, equals('0'));
      expect(listing.name, equals('Unknown Cow'));
      expect(listing.breed, equals('Unknown Breed'));
      expect(listing.price, equals(0.0));
      expect(listing.age, equals('N/A'));
      expect(listing.yieldAmount, equals('N/A'));
      expect(listing.location, equals('Unknown'));
      expect(listing.isVerified, isFalse);
    });
  });
}
