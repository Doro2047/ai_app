
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_app/features/apk_installer/repositories/adb_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdbClient', () {
    test('isInitialized returns false before initialize', () {
      final client = AdbClient();
      expect(client.isInitialized, false);
      expect(client.adbPath, isNull);
    });

    test('setAdbPath sets adb path and marks as initialized', () {
      final client = AdbClient();
      client.setAdbPath('/path/to/adb.exe');
      expect(client.isInitialized, true);
      expect(client.adbPath, '/path/to/adb.exe');
    });

    test('setAdbPath can override existing path', () {
      final client = AdbClient();
      client.setAdbPath('/path/to/adb.exe');
      expect(client.adbPath, '/path/to/adb.exe');

      client.setAdbPath('/another/path/to/adb.exe');
      expect(client.adbPath, '/another/path/to/adb.exe');
      expect(client.isInitialized, true);
    });

    test('devices throws AdbException when not initialized', () async {
      final client = AdbClient();
      expect(
        () => client.devices(),
        throwsA(isA<AdbException>()),
      );
    });

    test('install throws AdbException when not initialized', () async {
      final client = AdbClient();
      expect(
        () => client.install('/path/to/app.apk', 'device123'),
        throwsA(isA<AdbException>()),
      );
    });

    test('uninstall throws AdbException when not initialized', () async {
      final client = AdbClient();
      expect(
        () => client.uninstall('com.example.app', 'device123'),
        throwsA(isA<AdbException>()),
      );
    });

    test('shell throws AdbException when not initialized', () async {
      final client = AdbClient();
      expect(
        () => client.shell('ls -la', 'device123'),
        throwsA(isA<AdbException>()),
      );
    });

    test('push throws AdbException when not initialized', () async {
      final client = AdbClient();
      expect(
        () => client.push('/local/file.txt', '/remote/file.txt', 'device123'),
        throwsA(isA<AdbException>()),
      );
    });

    test('AdbException has correct message', () {
      const exception = AdbException('test error');
      expect(exception.message, 'test error');
      expect(exception.toString(), 'AdbException: test error');
    });

    test('AdbException implements Exception', () {
      const exception = AdbException('test');
      expect(exception, isA<Exception>());
    });

    test('ShellResult isSuccess returns true for exitCode 0', () {
      const result = ShellResult('output', '', 0);
      expect(result.isSuccess, true);
      expect(result.output, 'output');
      expect(result.errorOutput, '');
    });

    test('ShellResult isSuccess returns false for non-zero exitCode', () {
      const result = ShellResult('', 'error', 1);
      expect(result.isSuccess, false);
      expect(result.output, '');
      expect(result.errorOutput, 'error');
    });

    test('ShellResult trims output and errorOutput', () {
      const result = ShellResult('  output  \n', '  error  \n', 0);
      expect(result.output, 'output');
      expect(result.errorOutput, 'error');
    });

    test('AdbException not initialized message is correct', () {
      const exception = AdbException('ADB 未初始化，请先调�?initialize()');
      expect(exception.message, 'ADB 未初始化，请先调�?initialize()');
    });
  });
}
