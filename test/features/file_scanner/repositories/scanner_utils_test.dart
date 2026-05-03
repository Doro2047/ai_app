library;

/// FileScanner 工具函数单元测试
///
/// 测试文件格式格式化、文件类型判断和文本文件检测
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_app/features/file_scanner/models/file_scan_result.dart';

void main() {
  group('getFileType', () {
    test('returns text file for .txt', () {
      expect(getFileType('readme.txt'), '文本文件');
    });

    test('returns image file for .jpg', () {
      expect(getFileType('photo.jpg'), '图片');
      expect(getFileType('photo.jpeg'), '图片');
      expect(getFileType('photo.PNG'), '图片');
    });

    test('returns code file for source files', () {
      expect(getFileType('main.dart'), '代码文件');
      expect(getFileType('app.tsx'), '代码文件');
      expect(getFileType('index.js'), '代码文件');
      expect(getFileType('server.py'), '代码文件');
    });

    test('returns video file for video formats', () {
      expect(getFileType('movie.mp4'), '视频');
      expect(getFileType('clip.mkv'), '视频');
      expect(getFileType('recording.avi'), '视频');
    });

    test('returns audio file for audio formats', () {
      expect(getFileType('song.mp3'), '音频');
      expect(getFileType('track.flac'), '音频');
    });

    test('returns compressed file for archive formats', () {
      expect(getFileType('backup.zip'), '压缩文件');
      expect(getFileType('archive.tar.gz'), '压缩文件');
      expect(getFileType('data.7z'), '压缩文件');
    });

    test('returns executable for .exe', () {
      expect(getFileType('program.exe'), '可执行文件');
      expect(getFileType('installer.msi'), '可执行文件');
    });

    test('returns PDF for .pdf', () {
      expect(getFileType('document.pdf'), 'PDF文档');
    });

    test('returns spreadsheet for Excel files', () {
      expect(getFileType('data.xlsx'), '电子表格');
      expect(getFileType('report.xls'), '电子表格');
    });

    test('returns word doc for .docx', () {
      expect(getFileType('letter.docx'), '文档');
    });

    test('returns no extension for files without extension', () {
      expect(getFileType('README'), '无扩展名');
      expect(getFileType('Makefile'), '无扩展名');
    });

    test('returns no extension for files ending with dot', () {
      expect(getFileType('file.'), '无扩展名');
    });

    test('returns other file for unknown extensions', () {
      expect(getFileType('custom.xyz'), '其他文件');
      expect(getFileType('data.abc'), '其他文件');
    });

    test('handles case insensitivity', () {
      expect(getFileType('photo.JPG'), '图片');
      expect(getFileType('script.DART'), '代码文件');
      expect(getFileType('music.MP3'), '音频');
    });
  });

  group('formatSize', () {
    test('formats zero bytes', () {
      expect(formatSize(0), '0 B');
    });

    test('formats bytes under 1KB', () {
      expect(formatSize(500), '500 B');
      expect(formatSize(1023), '1023 B');
    });

    test('formats kilobytes', () {
      expect(formatSize(1024), '1.0 KB');
      expect(formatSize(1536), '1.5 KB');
      expect(formatSize(102400), '100.0 KB');
    });

    test('formats megabytes', () {
      expect(formatSize(1048576), '1.0 MB');
      expect(formatSize(5242880), '5.0 MB');
      expect(formatSize(104857600 - 1), '100.0 MB');
    });

    test('formats gigabytes', () {
      expect(formatSize(1073741824), '1.00 GB');
      expect(formatSize(5368709120), '5.00 GB');
    });
  });

  group('getSizeRangeName', () {
    test('returns 极小 for files under 1KB', () {
      expect(getSizeRangeName(0), '极小 (< 1KB)');
      expect(getSizeRangeName(512), '极小 (< 1KB)');
    });

    test('returns 小 for 1KB-100KB', () {
      expect(getSizeRangeName(1024), '小 (1KB - 100KB)');
      expect(getSizeRangeName(51200), '小 (1KB - 100KB)');
    });

    test('returns 中 for 100KB-1MB', () {
      expect(getSizeRangeName(102400), '中 (100KB - 1MB)');
      expect(getSizeRangeName(512000), '中 (100KB - 1MB)');
    });

    test('returns 大 for 1MB-10MB', () {
      expect(getSizeRangeName(1048576), '大 (1MB - 10MB)');
      expect(getSizeRangeName(5242880), '大 (1MB - 10MB)');
    });

    test('returns 极大 for 10MB-100MB', () {
      expect(getSizeRangeName(10485760), '极大 (10MB - 100MB)');
      expect(getSizeRangeName(52428800), '极大 (10MB - 100MB)');
    });

    test('returns 超大 for files over 100MB', () {
      expect(getSizeRangeName(104857600), '超大 (> 100MB)');
      expect(getSizeRangeName(1073741824), '超大 (> 100MB)');
    });
  });

  group('ScanConfig', () {
    test('default config has empty directories and extensions', () {
      const config = ScanConfig();

      expect(config.directories, isEmpty);
      expect(config.extensions, isEmpty);
      expect(config.maxSize, isNull);
      expect(config.minSize, isNull);
      expect(config.includeHidden, false);
      expect(config.recursive, true);
      expect(config.keepExtension, true);
    });

    test('copyWith updates only specified fields', () {
      const original = ScanConfig(
        directories: ['/home/user'],
        extensions: ['.txt'],
        recursive: true,
      );

      final updated = original.copyWith(
        recursive: false,
        minSize: 1024,
      );

      expect(updated.directories, ['/home/user']);
      expect(updated.extensions, ['.txt']);
      expect(updated.recursive, false);
      expect(updated.minSize, 1024);
      expect(updated.includeHidden, false);
    });

    test('custom config overrides defaults', () {
      const config = ScanConfig(
        directories: ['/path1', '/path2'],
        extensions: ['.jpg', '.png'],
        maxSize: 1000000,
        minSize: 100,
        includeHidden: true,
        recursive: false,
        keepExtension: false,
      );

      expect(config.directories, hasLength(2));
      expect(config.extensions, hasLength(2));
      expect(config.maxSize, 1000000);
      expect(config.minSize, 100);
      expect(config.includeHidden, true);
      expect(config.recursive, false);
      expect(config.keepExtension, false);
    });
  });

  group('FileScanResult', () {
    test('sizeFormatted returns formatted size', () {
      final result = FileScanResult(
        path: '/test/file.txt',
        name: 'file.txt',
        extension: '.txt',
        size: 1048576,
        modifiedTime: DateTime(2024, 1, 1, 12, 0, 0),
        isDirectory: false,
        fileType: '文本文件',
      );

      expect(result.sizeFormatted, '1.0 MB');
    });

    test('modifiedFormatted returns formatted date', () {
      final result = FileScanResult(
        path: '/test/file.txt',
        name: 'file.txt',
        extension: '.txt',
        size: 100,
        modifiedTime: DateTime(2024, 6, 15, 9, 30, 45),
        isDirectory: false,
        fileType: '文本文件',
      );

      expect(result.modifiedFormatted, '2024-06-15 09:30:45');
    });

    test('copyWith updates specified fields', () {
      final original = FileScanResult(
        path: '/test/file.txt',
        name: 'file.txt',
        extension: '.txt',
        size: 100,
        modifiedTime: DateTime(2024),
        isDirectory: false,
        fileType: '文本文件',
      );

      final updated = original.copyWith(size: 200, name: 'new_file.txt');

      expect(updated.size, 200);
      expect(updated.name, 'new_file.txt');
      expect(updated.path, original.path);
    });

    test('equality compares by path only', () {
      final r1 = FileScanResult(
        path: '/same/path',
        name: 'file1.txt',
        extension: '.txt',
        size: 100,
        modifiedTime: DateTime(2024),
        isDirectory: false,
        fileType: '文本文件',
      );

      final r2 = FileScanResult(
        path: '/same/path',
        name: 'file2.txt',
        extension: '.txt',
        size: 200,
        modifiedTime: DateTime(2025),
        isDirectory: true,
        fileType: '代码文件',
      );

      expect(r1, equals(r2));
    });
  });
}
