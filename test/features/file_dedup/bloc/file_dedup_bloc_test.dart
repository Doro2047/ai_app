import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_app/features/file_dedup/bloc/file_dedup_bloc.dart';
import 'package:ai_app/features/file_dedup/models/models.dart';
import 'package:ai_app/features/file_dedup/repositories/file_dedup_repository.dart';

class MockFileDedupRepository extends Mock implements FileDedupRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFileDedupRepository mockRepository;

  setUp(() {
    mockRepository = MockFileDedupRepository();
  });

  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(Completer<void>());
    registerFallbackValue((int a, int b) {});
    registerFallbackValue(<FileHashResult>[]);
  });

  group('FileDedupBloc', () {
    test('initial state has correct default values', () {
      final bloc = FileDedupBloc(repository: mockRepository);
      expect(bloc.state.directories, isEmpty);
      expect(bloc.state.isScanning, false);
      expect(bloc.state.isDeleting, false);
      expect(bloc.state.isScanComplete, false);
      expect(bloc.state.scanProgress, 0.0);
      expect(bloc.state.results, isEmpty);
      expect(bloc.state.duplicateGroups, isEmpty);
      expect(bloc.state.selectedFiles, isEmpty);
      expect(bloc.state.error, isNull);
      expect(bloc.state.deleteResult, isNull);
    });

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupDirectoriesSelected updates directories and resets scan state',
      build: () => FileDedupBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const FileDedupDirectoriesSelected(['/dir1', '/dir2'])),
      verify: (bloc) {
        expect(bloc.state.directories, ['/dir1', '/dir2']);
        expect(bloc.state.config.directories, ['/dir1', '/dir2']);
        expect(bloc.state.isScanComplete, false);
        expect(bloc.state.results, isEmpty);
        expect(bloc.state.duplicateGroups, isEmpty);
        expect(bloc.state.selectedFiles, isEmpty);
        expect(bloc.state.deleteResult, isNull);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupScanStarted emits error when directories is empty',
      build: () => FileDedupBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const FileDedupScanStarted()),
      verify: (bloc) {
        expect(bloc.state.error, '请先选择要扫描的目录');
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupScanStarted scans files and finds duplicates',
      build: () {
        final files = [
          FileHashResult(
            path: '/dir/file1.txt',
            name: 'file1.txt',
            size: 100,
            hash: 'abc123',
            hashType: 'md5',
            modified: DateTime(2024),
          ),
          FileHashResult(
            path: '/dir/file2.txt',
            name: 'file2.txt',
            size: 100,
            hash: 'abc123',
            hashType: 'md5',
            modified: DateTime(2024),
          ),
        ];
        final groups = [
          DuplicateGroup(
            hash: 'abc123',
            size: 100,
            files: files,
            selectedFiles: {'/dir/file2.txt'},
          ),
        ];

        when(() => mockRepository.scanFiles(
              any(),
              recursive: any(named: 'recursive'),
              cancelToken: any(named: 'cancelToken'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => files);
        when(() => mockRepository.findDuplicates(any())).thenReturn(groups);

        return FileDedupBloc(repository: mockRepository);
      },
      act: (bloc) {
        bloc
          ..add(const FileDedupDirectoriesSelected(['/dir']))
          ..add(const FileDedupScanStarted());
      },
      verify: (bloc) {
        verify(() => mockRepository.scanFiles(
              any(),
              recursive: any(named: 'recursive'),
              cancelToken: any(named: 'cancelToken'),
              onProgress: any(named: 'onProgress'),
            )).called(1);
        verify(() => mockRepository.findDuplicates(any())).called(1);
        expect(bloc.state.isScanning, false);
        expect(bloc.state.isScanComplete, true);
        expect(bloc.state.duplicateGroups, isNotEmpty);
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupScanStarted handles scan failure',
      build: () {
        when(() => mockRepository.scanFiles(
              any(),
              recursive: any(named: 'recursive'),
              cancelToken: any(named: 'cancelToken'),
              onProgress: any(named: 'onProgress'),
            )).thenThrow(Exception('scan error'));

        return FileDedupBloc(repository: mockRepository);
      },
      act: (bloc) {
        bloc
          ..add(const FileDedupDirectoriesSelected(['/dir']))
          ..add(const FileDedupScanStarted());
      },
      verify: (bloc) {
        expect(bloc.state.isScanning, false);
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupFileSelected updates selected files in group',
      build: () => FileDedupBloc(repository: mockRepository),
      seed: () => FileDedupState(
        directories: const ['/dir'],
        duplicateGroups: [
          DuplicateGroup(
            hash: 'abc123',
            size: 100,
            files: [
              FileHashResult(
                path: '/dir/file1.txt',
                name: 'file1.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
              FileHashResult(
                path: '/dir/file2.txt',
                name: 'file2.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
            ],
            selectedFiles: {},
          ),
        ],
        selectedFiles: const {},
      ),
      act: (bloc) => bloc.add(
        const FileDedupFileSelected('abc123', '/dir/file2.txt', true),
      ),
      verify: (bloc) {
        expect(bloc.state.selectedFiles, contains('/dir/file2.txt'));
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupDeleteRequested emits error when no files selected',
      build: () => FileDedupBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const FileDedupDeleteRequested()),
      verify: (bloc) {
        expect(bloc.state.error, '请先选择要删除的文件');
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupDeleteConfirmed deletes selected files',
      build: () {
        when(() => mockRepository.deleteFiles(
              any(),
              moveToTrash: any(named: 'moveToTrash'),
            )).thenAnswer((_) async => (['/dir/file2.txt'], <String>[]));

        return FileDedupBloc(repository: mockRepository);
      },
      seed: () => FileDedupState(
        directories: const ['/dir'],
        duplicateGroups: [
          DuplicateGroup(
            hash: 'abc123',
            size: 100,
            files: [
              FileHashResult(
                path: '/dir/file1.txt',
                name: 'file1.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
              FileHashResult(
                path: '/dir/file2.txt',
                name: 'file2.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
            ],
            selectedFiles: {'/dir/file2.txt'},
          ),
        ],
        selectedFiles: const {'/dir/file2.txt'},
        isScanComplete: true,
      ),
      act: (bloc) => bloc.add(const FileDedupDeleteConfirmed()),
      verify: (bloc) {
        verify(() => mockRepository.deleteFiles(
              any(),
              moveToTrash: any(named: 'moveToTrash'),
            )).called(1);
        expect(bloc.state.isDeleting, false);
        expect(bloc.state.deleteResult, isNotNull);
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupConfigChanged updates config',
      build: () => FileDedupBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const FileDedupConfigChanged(
        ScanConfig(hashType: 'sha256', recursive: false),
      )),
      verify: (bloc) {
        expect(bloc.state.config.hashType, 'sha256');
        expect(bloc.state.config.recursive, false);
        expect(bloc.state.isScanComplete, false);
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupSelectAll selects all but first in group',
      build: () => FileDedupBloc(repository: mockRepository),
      seed: () => FileDedupState(
        duplicateGroups: [
          DuplicateGroup(
            hash: 'abc123',
            size: 100,
            files: [
              FileHashResult(
                path: '/dir/file1.txt',
                name: 'file1.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
              FileHashResult(
                path: '/dir/file2.txt',
                name: 'file2.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
              FileHashResult(
                path: '/dir/file3.txt',
                name: 'file3.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
            ],
            selectedFiles: {},
          ),
        ],
        selectedFiles: const {},
      ),
      act: (bloc) => bloc.add(const FileDedupSelectAll('abc123')),
      verify: (bloc) {
        expect(bloc.state.selectedFiles, containsAll(['/dir/file2.txt', '/dir/file3.txt']));
        expect(bloc.state.selectedFiles, isNot(contains('/dir/file1.txt')));
      },
    );

    blocTest<FileDedupBloc, FileDedupState>(
      'FileDedupDeselectAll deselects all files in group',
      build: () => FileDedupBloc(repository: mockRepository),
      seed: () => FileDedupState(
        duplicateGroups: [
          DuplicateGroup(
            hash: 'abc123',
            size: 100,
            files: [
              FileHashResult(
                path: '/dir/file1.txt',
                name: 'file1.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
              FileHashResult(
                path: '/dir/file2.txt',
                name: 'file2.txt',
                size: 100,
                hash: 'abc123',
                hashType: 'md5',
                modified: DateTime(2024),
              ),
            ],
            selectedFiles: {'/dir/file2.txt'},
          ),
        ],
        selectedFiles: const {'/dir/file2.txt'},
      ),
      act: (bloc) => bloc.add(const FileDedupDeselectAll('abc123')),
      verify: (bloc) {
        expect(bloc.state.selectedFiles, isEmpty);
      },
    );
  });
}

