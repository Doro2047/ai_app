import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_app/shared/bloc/locale_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleBloc', () {
    test('initial state has Chinese locale', () {
      final bloc = LocaleBloc();
      expect(bloc.state.locale.languageCode, 'zh');
    });

    blocTest<LocaleBloc, LocaleState>(
      'LocaleChanged updates locale to English',
      build: () => LocaleBloc(),
      act: (bloc) => bloc.add(const LocaleChanged(Locale('en'))),
      verify: (bloc) {
        expect(bloc.state.locale.languageCode, 'en');
      },
    );

    blocTest<LocaleBloc, LocaleState>(
      'LocaleChanged updates locale back to Chinese',
      build: () => LocaleBloc(),
      seed: () => const LocaleState(locale: Locale('en')),
      act: (bloc) => bloc.add(const LocaleChanged(Locale('zh'))),
      verify: (bloc) {
        expect(bloc.state.locale.languageCode, 'zh');
      },
    );

    blocTest<LocaleBloc, LocaleState>(
      'LocaleChanged with same locale still emits state',
      build: () => LocaleBloc(),
      act: (bloc) => bloc.add(const LocaleChanged(Locale('zh'))),
      verify: (bloc) {
        expect(bloc.state.locale.languageCode, 'zh');
      },
    );
  });

  group('LocaleState', () {
    test('default locale is Chinese', () {
      const state = LocaleState();
      expect(state.locale.languageCode, 'zh');
    });

    test('copyWith updates locale', () {
      const state = LocaleState();
      final newState = state.copyWith(locale: const Locale('en'));
      expect(newState.locale.languageCode, 'en');
    });

    test('equality compares languageCode', () {
      const state1 = LocaleState(locale: Locale('zh'));
      const state2 = LocaleState(locale: Locale('zh'));
      const state3 = LocaleState(locale: Locale('en'));

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('supportedLocales contains zh and en', () {
      expect(LocaleState.supportedLocales.length, 2);
      expect(LocaleState.supportedLocales.any((l) => l.languageCode == 'zh'), true);
      expect(LocaleState.supportedLocales.any((l) => l.languageCode == 'en'), true);
    });
  });
}
