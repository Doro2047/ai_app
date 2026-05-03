import 'package:flutter_test/flutter_test.dart';

import 'package:extension_changer/main.dart';

void main() {
  testWidgets('App renders ExtensionChangerPage', (WidgetTester tester) async {
    await tester.pumpWidget(const ExtensionChangerApp());
    expect(find.text('Extension Changer'), findsOneWidget);
  });
}
