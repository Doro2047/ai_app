import 'package:flutter_test/flutter_test.dart';

import 'package:ai_app/core/storage/data_migrator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegacyDataInfo', () {
    test('hasAnyData returns false when no data exists', () {
      const info = LegacyDataInfo();
      expect(info.hasAnyData, false);
    });

    test('hasAnyData returns true when hasConfig is true', () {
      const info = LegacyDataInfo(hasConfig: true);
      expect(info.hasAnyData, true);
    });

    test('hasAnyData returns true when hasPrograms is true', () {
      const info = LegacyDataInfo(hasPrograms: true);
      expect(info.hasAnyData, true);
    });

    test('hasAnyData returns true when hasCategories is true', () {
      const info = LegacyDataInfo(hasCategories: true);
      expect(info.hasAnyData, true);
    });

    test('hasAnyData returns true when hasThemeConfig is true', () {
      const info = LegacyDataInfo(hasThemeConfig: true);
      expect(info.hasAnyData, true);
    });

    test('hasAnyData returns true when hasCustomThemes is true', () {
      const info = LegacyDataInfo(hasCustomThemes: true);
      expect(info.hasAnyData, true);
    });

    test('hasAnyData returns true when multiple flags are true', () {
      const info = LegacyDataInfo(
        hasConfig: true,
        hasPrograms: true,
        hasCategories: true,
      );
      expect(info.hasAnyData, true);
    });

    test('directoryPath is null by default', () {
      const info = LegacyDataInfo();
      expect(info.directoryPath, isNull);
    });

    test('directoryPath can be set', () {
      const info = LegacyDataInfo(directoryPath: '/some/path');
      expect(info.directoryPath, '/some/path');
    });
  });

  group('MigrationResult', () {
    test('successful migration result', () {
      const result = MigrationResult(
        success: true,
        message: '迁移完成',
        migratedCount: 10,
        sourceCount: 10,
      );
      expect(result.success, true);
      expect(result.message, '迁移完成');
      expect(result.migratedCount, 10);
      expect(result.sourceCount, 10);
    });

    test('failed migration result', () {
      const result = MigrationResult(
        success: false,
        message: '迁移失败',
      );
      expect(result.success, false);
      expect(result.message, '迁移失败');
      expect(result.migratedCount, 0);
      expect(result.sourceCount, 0);
    });

    test('default values are zero for counts', () {
      const result = MigrationResult(
        success: true,
        message: 'ok',
      );
      expect(result.migratedCount, 0);
      expect(result.sourceCount, 0);
    });

    test('toString contains relevant info', () {
      const result = MigrationResult(
        success: true,
        message: '完成',
        migratedCount: 5,
        sourceCount: 5,
      );
      final str = result.toString();
      expect(str, contains('true'));
      expect(str, contains('完成'));
      expect(str, contains('5'));
    });
  });

  group('DataMigrator', () {
    test('isInitialized returns false before init', () {
      final migrator = DataMigrator();
      expect(migrator.isInitialized, false);
    });

    test('isMigrationDone returns false before migration', () {
      final migrator = DataMigrator();
      expect(migrator.isMigrationDone, false);
    });

    test('migrationVersion is null before migration', () {
      final migrator = DataMigrator();
      expect(migrator.migrationVersion, isNull);
    });

    test('migrationDate is null before migration', () {
      final migrator = DataMigrator();
      expect(migrator.migrationDate, isNull);
    });

    test('detectLegacyData returns LegacyDataInfo', () async {
      final migrator = DataMigrator();
      final info = await migrator.detectLegacyData();
      expect(info, isA<LegacyDataInfo>());
    });

    test('detectLegacyData returns no data on clean system', () async {
      final migrator = DataMigrator();
      final info = await migrator.detectLegacyData();
      expect(info.hasAnyData, false);
    });

    test('isMigrationNeeded returns false when no legacy data', () async {
      final migrator = DataMigrator();
      final needed = await migrator.isMigrationNeeded();
      expect(needed, false);
    });

    test('migrateConfig returns success when no legacy data', () async {
      final migrator = DataMigrator();
      final result = await migrator.migrateConfig();
      expect(result, isA<MigrationResult>());
      expect(result.success, true);
      expect(result.message, contains('无需迁移'));
    });

    test('migratePrograms returns success when no legacy data', () async {
      final migrator = DataMigrator();
      final result = await migrator.migratePrograms();
      expect(result, isA<MigrationResult>());
      expect(result.success, true);
      expect(result.message, contains('无需迁移'));
    });

    test('migrateCategories returns success when no legacy data', () async {
      final migrator = DataMigrator();
      final result = await migrator.migrateCategories();
      expect(result, isA<MigrationResult>());
      expect(result.success, true);
      expect(result.message, contains('无需迁移'));
    });

    test('migrateThemes returns success when no legacy data', () async {
      final migrator = DataMigrator();
      final result = await migrator.migrateThemes();
      expect(result, isA<MigrationResult>());
      expect(result.success, true);
      expect(result.message, contains('无需迁移'));
    });

    test('verifyMigration returns true when no legacy data', () async {
      final migrator = DataMigrator();
      final result = await migrator.verifyMigration();
      expect(result, true);
    });

    test('backupLegacyData returns null when no legacy data', () async {
      final migrator = DataMigrator();
      final result = await migrator.backupLegacyData();
      expect(result, isNull);
    });

    test('migrateAll returns list of MigrationResult', () async {
      final migrator = DataMigrator();
      final results = await migrator.migrateAll();
      expect(results, isA<List<MigrationResult>>());
      expect(results, isNotEmpty);
      for (final result in results) {
        expect(result, isA<MigrationResult>());
      }
    });

    test('migrateAll all results are successful when no legacy data', () async {
      final migrator = DataMigrator();
      final results = await migrator.migrateAll();
      for (final result in results) {
        expect(result.success, true);
      }
    });
  });
}
