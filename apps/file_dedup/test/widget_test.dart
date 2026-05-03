import 'package:flutter_test/flutter_test.dart';

import 'package:file_dedup/main.dart';

void main() {
  testWidgets('App renders FileDedupPage', (WidgetTester tester) async {
    await tester.pumpWidget(const FileDedupApp());

    expect(find.text('File Dedup Cleaner'), findsOneWidget);
  });
}
