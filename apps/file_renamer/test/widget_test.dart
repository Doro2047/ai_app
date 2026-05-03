import 'package:flutter_test/flutter_test.dart';

import 'package:file_renamer/main.dart';

void main() {
  testWidgets('App renders FileRenamerPage', (WidgetTester tester) async {
    await tester.pumpWidget(const FileRenamerApp());

    expect(find.text('Batch Rename Tool'), findsOneWidget);
  });
}
