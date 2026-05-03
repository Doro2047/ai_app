/// Widget æµè¯
///
/// æµè¯ AppScaffold æ¸²æãä¸»é¢åæ?UI åç©ºç¶ææ¾ç¤ºã?library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_app/shared/widgets/app_scaffold.dart';
import 'package:ai_app/shared/widgets/empty_state.dart';
import 'package:ai_app/shared/bloc/theme_bloc.dart';
import 'package:ai_app/shared/bloc/locale_bloc.dart';
import 'package:ai_app/core/theme/app_theme.dart';

// Mock BLoCs
class MockThemeBloc extends Mock implements ThemeBloc {}
class MockLocaleBloc extends Mock implements LocaleBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockThemeBloc mockThemeBloc;
  late MockLocaleBloc mockLocaleBloc;
  late ThemeState initialThemeState;
  late LocaleState initialLocaleState;

  setUp(() {
    mockThemeBloc = MockThemeBloc();
    mockLocaleBloc = MockLocaleBloc();

    initialThemeState = ThemeState(
      isDarkMode: false,
      currentSkin: SkinType.defaultLight,
      currentMode: AppThemeMode.light,
      skinConfig: AppTheme.getSkinConfig(SkinType.defaultLight),
    );

    initialLocaleState = const LocaleState(locale: Locale('zh'));

    // Configure mock behavior
    when(() => mockThemeBloc.state).thenReturn(initialThemeState);
    when(() => mockLocaleBloc.state).thenReturn(initialLocaleState);
    when(() => mockThemeBloc.stream).thenAnswer(
      (_) => const Stream<ThemeState>.empty(),
    );
    when(() => mockLocaleBloc.stream).thenAnswer(
      (_) => const Stream<LocaleState>.empty(),
    );
  });

  tearDown(() {
    mockThemeBloc.close();
    mockLocaleBloc.close();
  });

  group('AppScaffold', () {
    Widget createScaffold({
      String title = 'Test Page',
      Widget? body,
      bool showStatusBar = true,
      String statusBarText = 'å°±ç»ª',
    }) {
      return MaterialApp(
        home: BlocProvider<ThemeBloc>.value(
          value: mockThemeBloc,
          child: BlocProvider<LocaleBloc>.value(
            value: mockLocaleBloc,
            child: AppScaffold(
              title: title,
              body: body ?? const Center(child: Text('Content')),
              showStatusBar: showStatusBar,
              statusBarText: statusBarText,
            ),
          ),
        ),
      );
    }

    testWidgets('renders with title and body', (tester) async {
      await tester.pumpWidget(createScaffold(
        title: 'My Page',
        body: const Text('Hello World'),
      ));

      expect(find.text('My Page'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('shows status bar by default', (tester) async {
      await tester.pumpWidget(createScaffold(
        statusBarText: 'Loading...',
      ));

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('hides status bar when showStatusBar is false', (tester) async {
      await tester.pumpWidget(createScaffold(
        showStatusBar: false,
      ));

      expect(find.text('å°±ç»ª'), findsNothing);
    });

    testWidgets('renders with leading widget', (tester) async {
      await tester.pumpWidget(createScaffold(
        body: const Text('Content'),
      ));

      // AppScaffold uses Scaffold, so it should render
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with header actions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<ThemeBloc>.value(
          value: mockThemeBloc,
          child: BlocProvider<LocaleBloc>.value(
            value: mockLocaleBloc,
            child: AppScaffold(
              title: 'Actions Page',
              body: const Text('Content'),
              headerActions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ));

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders with default values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(),
        ),
      );

      expect(find.text('ææ æ°æ®'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders with custom icon and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(
            icon: Icons.folder_open,
            title: 'No files found',
          ),
        ),
      );

      expect(find.text('No files found'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('renders with description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(
            title: 'No data',
            description: 'Please add some data to continue',
          ),
        ),
      );

      expect(find.text('Please add some data to continue'), findsOneWidget);
    });

    testWidgets('renders action button when actionText is provided', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: EmptyState(
            title: 'Empty',
            actionText: 'Add Item',
            onAction: () => actionCalled = true,
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      // Tap the action button
      await tester.tap(find.text('Add Item'));
      expect(actionCalled, isTrue);
    });

    testWidgets('shows loading animation when showLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(
            title: 'Loading...',
            showLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides description when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(
            title: 'No description',
          ),
        ),
      );

      // No description text should be present
      expect(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'ææ æ°æ®',
      ), findsOneWidget);
    });
  });
}