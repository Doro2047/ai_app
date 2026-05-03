import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_app/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app starts and shows home page', (tester) async {
      await tester.pumpWidget(const AiApp());
      await tester.pumpAndSettle();

      expect(find.text('AI Apps 工具集'), findsOneWidget);
    });

    testWidgets('search button is visible on home page', (tester) async {
      await tester.pumpWidget(const AiApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('category tabs are visible', (tester) async {
      await tester.pumpWidget(const AiApp());
      await tester.pumpAndSettle();

      expect(find.text('全部'), findsOneWidget);
      expect(find.text('文件管理'), findsOneWidget);
      expect(find.text('系统工具'), findsOneWidget);
    });

    testWidgets('theme toggle is accessible', (tester) async {
      await tester.pumpWidget(const AiApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });
  });
}
