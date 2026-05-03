import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_app/features/extension_changer/bloc/extension_changer_bloc.dart';
import 'package:ai_app/features/extension_changer/models/extension_rule.dart';
import 'package:ai_app/features/extension_changer/models/file_preview.dart';
import 'package:ai_app/features/extension_changer/repositories/extension_changer_repository.dart';
import 'package:ai_app/features/file_scanner/models/file_scan_result.dart';

class MockExtensionChangerRepository extends Mock
    implements ExtensionChangerRepository {}

class _ProgressCallback {
  final int completed;
  final int total;
  const _ProgressCallback(this.completed, this.total);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExtensionChangerRepository mockRepository;

  setUp(() {
    mockRepository = MockExtensionChangerRepository();
  });

  setUpAll(() {
    registerFallbackValue(<FileScanResult>[]);
    registerFallbackValue(<ExtensionRule>[]);
    registerFallbackValue(<FilePreview>[]);
    registerFallbackValue(const _ProgressCallback(0, 1));
  });

  group('ExtensionChangerBloc', () {
    test('initial state has correct default values', () {
      final bloc = ExtensionChangerBloc(repository: mockRepository);
      expect(bloc.state.directory, isEmpty);
      expect(bloc.state.files, isEmpty);
      expect(bloc.state.rules, isEmpty);
      expect(bloc.state.previews, isEmpty);
      expect(bloc.state.isScanning, false);
      expect(bloc.state.isExecuting, false);
      expect(bloc.state.progress, 0.0);
      expect(bloc.state.error, isNull);
    });

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'DirectorySelected updates directory and resets files and previews',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const DirectorySelected('/test/dir')),
      verify: (bloc) {
        expect(bloc.state.directory, '/test/dir');
        expect(bloc.state.files, isEmpty);
        expect(bloc.state.previews, isEmpty);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'RuleAdded adds rule to rules list',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const RuleAdded(
        ExtensionRule(originalExtension: '.txt', newExtension: '.md'),
      )),
      verify: (bloc) {
        expect(bloc.state.rules.length, 1);
        expect(bloc.state.rules.first.originalExtension, '.txt');
        expect(bloc.state.rules.first.newExtension, '.md');
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'RuleAdded adds multiple rules',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      act: (bloc) {
        bloc
          ..add(const RuleAdded(
            ExtensionRule(originalExtension: '.txt', newExtension: '.md'),
          ))
          ..add(const RuleAdded(
            ExtensionRule(originalExtension: '.jpg', newExtension: '.png'),
          ));
      },
      verify: (bloc) {
        expect(bloc.state.rules.length, 2);
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'PreviewRequested emits error when files is empty',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const PreviewRequested()),
      verify: (bloc) {
        expect(bloc.state.error, '请先扫描目录获取文件列表');
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'PreviewRequested emits error when rules is empty',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      seed: () => ExtensionChangerState(
        files: [
          FileScanResult(
            path: '/test/file.txt',
            name: 'file.txt',
            extension: '.txt',
            size: 100,
            modifiedTime: DateTime(2024),
            isDirectory: false,
            fileType: 'ææ¬æä»¶',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const PreviewRequested()),
      verify: (bloc) {
        expect(bloc.state.error, '请至少添加一个扩展名修改规则');
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'PreviewRequested generates previews from files and rules',
      build: () {
        when(() => mockRepository.applyRules(any(), any())).thenReturn([
          const FilePreview(
            originalPath: '/test/file.txt',
            originalName: 'file.txt',
            newName: 'file.md',
          ),
        ]);

        return ExtensionChangerBloc(repository: mockRepository);
      },
      seed: () => ExtensionChangerState(
        files: [
          FileScanResult(
            path: '/test/file.txt',
            name: 'file.txt',
            extension: '.txt',
            size: 100,
            modifiedTime: DateTime(2024),
            isDirectory: false,
            fileType: 'ææ¬æä»¶',
          ),
        ],
        rules: [
          const ExtensionRule(originalExtension: '.txt', newExtension: '.md'),
        ],
      ),
      act: (bloc) => bloc.add(const PreviewRequested()),
      verify: (bloc) {
        verify(() => mockRepository.applyRules(any(), any())).called(1);
        expect(bloc.state.previews.length, 1);
        expect(bloc.state.previews.first.newName, 'file.md');
        expect(bloc.state.isScanning, false);
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'ExecuteRequested emits error when previews is empty',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ExecuteRequested()),
      verify: (bloc) {
        expect(bloc.state.error, '请先生成预览');
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'ExecuteRequested emits error when no changes in previews',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      seed: () => const ExtensionChangerState(
        previews: [
          FilePreview(
            originalPath: '/test/file.txt',
            originalName: 'file.txt',
            newName: 'file.txt',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const ExecuteRequested()),
      verify: (bloc) {
        expect(bloc.state.error, '没有需要修改扩展名的文件');
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'ExecuteRequested executes rename and updates preview status',
      build: () {
        when(() => mockRepository.executeRename(
              any(),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => (
              <FilePreview>[
                const FilePreview(
                  originalPath: '/test/file.txt',
                  originalName: 'file.txt',
                  newName: 'file.md',
                  status: ExtensionChangeStatus.success,
                ),
              ],
              <FilePreview>[],
            ));

        return ExtensionChangerBloc(repository: mockRepository);
      },
      seed: () => const ExtensionChangerState(
        previews: [
          FilePreview(
            originalPath: '/test/file.txt',
            originalName: 'file.txt',
            newName: 'file.md',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const ExecuteRequested()),
      verify: (bloc) {
        verify(() => mockRepository.executeRename(
              any(),
              onProgress: any(named: 'onProgress'),
            )).called(1);
        expect(bloc.state.isExecuting, false);
        expect(bloc.state.progress, 1.0);
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'RuleRemoved removes rule at index',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      seed: () => const ExtensionChangerState(
        rules: [
          ExtensionRule(originalExtension: '.txt', newExtension: '.md'),
          ExtensionRule(originalExtension: '.jpg', newExtension: '.png'),
        ],
      ),
      act: (bloc) => bloc.add(const RuleRemoved(0)),
      verify: (bloc) {
        expect(bloc.state.rules.length, 1);
        expect(bloc.state.rules.first.originalExtension, '.jpg');
      },
    );

    blocTest<ExtensionChangerBloc, ExtensionChangerState>(
      'CancelRequested resets scanning and executing state',
      build: () => ExtensionChangerBloc(repository: mockRepository),
      seed: () => const ExtensionChangerState(
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
  });
}
