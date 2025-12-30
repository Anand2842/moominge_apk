import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/models/cow_listing.dart';
import 'package:moomingle/widgets/cow_card.dart';

void main() {
  group('CowCard Widget', () {
    late CowListing testListing;

    setUp(() {
      testListing = CowListing(
        id: 'test-id',
        name: 'Test Cow',
        breed: 'Gir',
        age: '3',
        price: 50000.0,
        location: 'Gujarat',
        yieldAmount: '10L',
        imageUrl: 'https://example.com/image.jpg',
        sellerName: 'Test Seller',
        isVerified: true,
      );
    });

    testWidgets('should display cow information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CowCard(cow: testListing),
          ),
        ),
      );

      expect(find.text('Test Cow'), findsOneWidget);
      expect(find.text('Gir'), findsOneWidget);
      expect(find.text('Gujarat'), findsOneWidget);
    });

    testWidgets('should show verified badge when verified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CowCard(cow: testListing),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('should not show verified badge when not verified', (WidgetTester tester) async {
      final unverifiedListing = CowListing(
        id: 'test-id',
        name: 'Test Cow',
        breed: 'Gir',
        age: '3',
        price: 50000.0,
        location: 'Gujarat',
        yieldAmount: '10L',
        imageUrl: 'https://example.com/image.jpg',
        isVerified: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CowCard(cow: unverifiedListing),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('should display formatted price', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CowCard(cow: testListing),
          ),
        ),
      );

      expect(find.textContaining('50,000'), findsOneWidget);
    });
  });
}
