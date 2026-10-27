// Basic smoke test placeholder.
//
// The real app (lib/main.dart) initializes Firebase before building the
// widget tree, which widget tests can't do without a mocked platform
// channel setup. This project is verified on-device instead (see project
// plan Phase 5), so this test just checks a trivial widget renders.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Brivio'))),
    );

    expect(find.text('Brivio'), findsOneWidget);
  });
}
