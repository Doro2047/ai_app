import 'package:flutter_test/flutter_test.dart';

import 'package:file_mover/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FileMoverApp());
    expect(find.text('File Mover'), findsOneWidget);
  });
}
