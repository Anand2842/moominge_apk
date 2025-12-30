import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/models/cow_listing.dart';

/// Test helpers and utilities for Moomingle tests

/// Create a mock CowListing for testing
CowListing createMockListing({
  String id = 'test-id',
  String name = 'Test Cow',
  String breed = 'Gir',
  String age = '3',
  double price = 50000.0,
  String location = 'Gujarat',
  bool isVerified = false,
}) {
  return CowListing(
    id: id,
    name: name,
    breed: breed,
    age: age,
    price: price,
    location: location,
    yieldAmount: '10L',
    imageUrl: 'https://example.com/image.jpg',
    sellerName: 'Test Seller',
    isVerified: isVerified,
  );
}

/// Create a list of mock listings
List<CowListing> createMockListings(int count) {
  return List.generate(
    count,
    (index) => createMockListing(
      id: 'test-id-$index',
      name: 'Test Cow $index',
      price: 50000.0 + (index * 10000.0),
    ),
  );
}

/// Pump a widget with MaterialApp wrapper
Future<void> pumpWidgetWithMaterial(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    ),
  );
}

/// Wait for animations and async operations
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle(timeout);
}

/// Find text containing a substring (case insensitive)
Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.toLowerCase().contains(text.toLowerCase()),
  );
}

/// Verify no exceptions were thrown
void expectNoExceptions(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

/// Mock data for testing
class MockData {
  static const String mockImageUrl = 'https://example.com/image.jpg';
  static const String mockUserId = 'test-user-id';
  static const String mockSellerId = 'test-seller-id';
  static const String mockListingId = 'test-listing-id';
  static const String mockChatId = 'test-chat-id';

  static final List<String> breeds = [
    'Gir',
    'Sahiwal',
    'Murrah',
    'Kankrej',
    'Ongole',
  ];

  static final List<String> locations = [
    'Gujarat',
    'Punjab',
    'Haryana',
    'Rajasthan',
    'Maharashtra',
  ];
}
