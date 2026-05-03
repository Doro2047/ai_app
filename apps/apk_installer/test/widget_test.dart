import 'package:flutter_test/flutter_test.dart';

import 'package:apk_installer/main.dart';

void main() {
  testWidgets('App renders ApkInstallerPage', (WidgetTester tester) async {
    await tester.pumpWidget(const ApkInstallerApp());

    expect(find.text('APK Batch Installer'), findsOneWidget);
  });
}
