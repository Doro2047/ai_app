import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_app/features/file_mover/bloc/file_mover_bloc.dart';
import 'package:ai_app/features/file_mover/models/move_preview.dart';
import 'package:ai_app/features/file_mover/models/move_rule.dart';
import 'package:ai_app/features/file_mover/repositories/file_mover_repository.dart';
import 'package:ai_app/features/file_scanner/models/file_scan_result.dart';

class MockFileMoverRepository extends Mock implements FileMoverRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFileMoverRepository mockRepository;

  setUp(() {
    mockRepository = MockFileMoverRepository();
  });

  setUpAll(() {
    registerFallbackValue(<FileScanResult>[]);
    registerFallbackValue(<MoveRule>[]);
    registerFallbackValue(<MovePreview>[]);
  });

  group('FileMoverBloc', () {
    test('initial state has correct default values', () {
      final bloc = FileMoverBloc(repository: mockRepository);
      expect(bloc.state.sourceDirectory, isEmpty);
      expect(bloc.state.targetDirectory, isEmpty);
      expect(bloc.state.files, isEmpty);
      expect(bloc.state.rules, isEmpty);
      expect(bloc.state.previews, isEmpty);
      expect(bloc.state.isScanning, false);
      expect(bloc.state.isExecuting, false);
      expect(bloc.state.progress, 0.0);
      expect(bloc.state.error, isNull);
    });

    blocTest<FileMoverBloc, FileMoverState>(
      'SourceDirectorySelected updates source directory and resets files and previews',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const SourceDirectorySelected('/source/dir')),
      verify: (bloc) {
        expect(bloc.state.sourceDirectory, '/source/dir');
        expect(bloc.state.files, isEmpty);
        expect(bloc.state.previews, isEmpty);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'TargetDirectorySelected updates target directory',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const TargetDirectorySelected('/target/dir')),
      verify: (bloc) {
        expect(bloc.state.targetDirectory, '/target/dir');
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'RuleAdded adds rule to rules list',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) => bloc.add(RuleAdded(
        MoveRule(
          matchType: MatchType.extension,
          matchPattern: '.txt',
          targetDirectory: '/target/docs',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.rules.length, 1);
        expect(bloc.state.rules.first.matchType, MatchType.extension);
        expect(bloc.state.rules.first.matchPattern, '.txt');
        expect(bloc.state.rules.first.targetDirectory, '/target/docs');
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'RuleAdded adds multiple rules',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) {
        bloc
          ..add(RuleAdded(
            MoveRule(
              matchType: MatchType.extension,
              matchPattern: '.txt',
              targetDirectory: '/target/docs',
            ),
          ))
          ..add(RuleAdded(
            MoveRule(
              matchType: MatchType.name,
              matchPattern: 'readme',
              targetDirectory: '/target/readme',
            ),
          ));
      },
      verify: (bloc) {
        expect(bloc.state.rules.length, 2);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'PreviewRequested emits error when files is empty',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const PreviewRequested()),
      verify: (bloc) {
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'PreviewRequested emits error when no rules and no target directory',
      build: () => FileMoverBloc(repository: mockRepository),
      seed: () => FileMoverState(
        files: [
          FileScanResult(
            path: '/source/file.txt',
            name: 'file.txt',
            extension: '.txt',
            size: 100,
            modifiedTime: DateTime(2024),
            isDirectory: false,
            fileType: 'text',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const PreviewRequested()),
      verify: (bloc) {
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'PreviewRequested generates previews from files and rules',
      build: () {
        when(() => mockRepository.applyRules(
              any(),
              any(),
              targetDirectory: any(named: 'targetDirectory'),
            )).thenReturn([
          const MovePreview(
            originalPath: '/source/file.txt',
            originalName: 'file.txt',
            targetPath: '/target/docs/file.txt',
          ),
        ]);

        return FileMoverBloc(repository: mockRepository);
      },
      seed: () => FileMoverState(
        files: [
          FileScanResult(
            path: '/source/file.txt',
            name: 'file.txt',
            extension: '.txt',
            size: 100,
            modifiedTime: DateTime(2024),
            isDirectory: false,
            fileType: 'text',
          ),
        ],
        rules: [
          MoveRule(
            matchType: MatchType.extension,
            matchPattern: '.txt',
            targetDirectory: '/target/docs',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const PreviewRequested()),
      verify: (bloc) {
        verify(() => mockRepository.applyRules(
              any(),
              any(),
              targetDirectory: any(named: 'targetDirectory'),
            )).called(1);
        expect(bloc.state.previews.length, 1);
        expect(bloc.state.previews.first.targetPath, '/target/docs/file.txt');
        expect(bloc.state.isScanning, false);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'RuleRemoved removes rule at index',
      build: () => FileMoverBloc(repository: mockRepository),
      seed: () => const FileMoverState(
        rules: [
          MoveRule(
            matchType: MatchType.extension,
            matchPattern: '.txt',
            targetDirectory: '/target/docs',
          ),
          MoveRule(
            matchType: MatchType.name,
            matchPattern: 'readme',
            targetDirectory: '/target/readme',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const RuleRemoved(0)),
      verify: (bloc) {
        expect(bloc.state.rules.length, 1);
        expect(bloc.state.rules.first.matchType, MatchType.name);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'CancelRequested resets scanning and executing state',
      build: () => FileMoverBloc(repository: mockRepository),
      seed: () => const FileMoverState(
        isScanning: true,
        isExecuting: true,
        progress: 0.5,
      ),
      act: (bloc) => bloc.add(const CancelRequested()),
      verify: (bloc) {
        expect(bloc.state.isScanning, false);
        expect(bloc.state.isExecuting, false);
        expect(bloc.state.progress, 0.0);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'ScanRequested emits error when source directory is empty',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ScanRequested()),
      verify: (bloc) {
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<FileMoverBloc, FileMoverState>(
      'ExecuteRequested emits error when previews is empty',
      build: () => FileMoverBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ExecuteRequested()),
      verify: (bloc) {
        expect(bloc.state.error, isNotNull);
      },
    );
  });
}
