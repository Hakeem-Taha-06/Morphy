// Widget test for Morphy camera UI
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:morphy/main.dart';

void main() {
  testWidgets('Camera screen smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MorphyApp());

    // Verify the app title is shown
    expect(find.text('Morphy'), findsOneWidget);

    // Verify camera preview placeholder is shown
    expect(find.text('Camera Preview'), findsOneWidget);

    // Verify capture button exists
    expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
  });
}
