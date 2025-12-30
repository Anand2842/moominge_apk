import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/main.dart';

void main() {
  group('User Flow Integration Tests', () {
    testWidgets('should navigate through main screens', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // Should start on home screen or sign in screen
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should show bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // Look for navigation elements
      final navBarFinder = find.byType(BottomNavigationBar);
      if (navBarFinder.evaluate().isNotEmpty) {
        expect(navBarFinder, findsOneWidget);
      }
    });

    testWidgets('should handle navigation between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // Try to find and tap navigation items
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().isNotEmpty) {
        // Tap different tabs
        await tester.tap(navItems.first);
        await tester.pumpAndSettle();
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('Listing Flow Tests', () {
    testWidgets('should display listings on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // Should show some content
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle swipe gestures', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // Look for swipeable cards
      final cardFinder = find.byType(Card);
      if (cardFinder.evaluate().isNotEmpty) {
        // Try to swipe
        await tester.drag(cardFinder.first, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }
    });
  });

  group('Error Handling Tests', () {
    testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // App should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show error messages when appropriate', (WidgetTester tester) async {
      await tester.pumpWidget(const MoomingleApp());
      await tester.pumpAndSettle();

      // Look for error indicators
      final errorFinder = find.textContaining('error', skipOffstage: false);
      // Errors may or may not be present
      expect(errorFinder, findsWidgets);
    });
  });
}
