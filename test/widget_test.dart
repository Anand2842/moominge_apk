import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoomingleApp());

    // Verify app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
