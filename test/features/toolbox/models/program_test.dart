/// ProgramInfo æ¨¡åååæµè¯
///
/// æµè¯ ProgramInfo çåºåå/ååºååãcopyWith æ¹æ³åç¸ç­æ§ã?library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_app/features/toolbox/models/program.dart';

void main() {
  group('ProgramInfo', () {
    test('default values are set correctly', () {
      const program = ProgramInfo(
        id: 'test-1',
        name: 'Test Program',
        path: 'C:/test/program.exe',
      );

      expect(program.icon, '');
      expect(program.category, 'all');
      expect(program.description, '');
      expect(program.useCount, 0);
      expect(program.lastUsed, '');
      expect(program.createdAt, '');
      expect(program.version, '');
      expect(program.sourceDir, '');
      expect(program.enabled, true);
      expect(program.isToolLibrary, false);
    });

    test('all fields can be set', () {
      final program = ProgramInfo(
        id: 'test-2',
        name: 'Full Program',
        path: 'C:/full/program.exe',
        icon: 'C:/icon.png',
        category: 'tools',
        description: 'A test program',
        useCount: 5,
        lastUsed: '2024-01-01',
        createdAt: '2024-01-01',
        version: '1.0.0',
        sourceDir: 'C:/src',
        enabled: false,
        isToolLibrary: true,
      );

      expect(program.id, 'test-2');
      expect(program.name, 'Full Program');
      expect(program.path, 'C:/full/program.exe');
      expect(program.icon, 'C:/icon.png');
      expect(program.category, 'tools');
      expect(program.description, 'A test program');
      expect(program.useCount, 5);
      expect(program.lastUsed, '2024-01-01');
      expect(program.createdAt, '2024-01-01');
      expect(program.version, '1.0.0');
      expect(program.sourceDir, 'C:/src');
      expect(program.enabled, false);
      expect(program.isToolLibrary, true);
    });
  });

  group('ProgramInfo.fromDict', () {
    test('deserializes from JSON map with standard keys', () {
      final data = {
        'id': 'json-1',
        'name': 'JSON Program',
        'path': 'C:/json/app.exe',
        'icon': 'icon.png',
        'category': 'productivity',
        'description': 'From JSON',
        'useCount': 10,
        'lastUsed': '2024-06-01',
        'createdAt': '2024-01-01',
        'version': '2.0.0',
        'sourceDir': 'C:/source',
        'enabled': true,
        'isToolLibrary': false,
      };

      final program = ProgramInfo.fromDict(data);

      expect(program.id, 'json-1');
      expect(program.name, 'JSON Program');
      expect(program.path, 'C:/json/app.exe');
      expect(program.useCount, 10);
      expect(program.enabled, true);
    });

    test('deserializes from JSON map with snake_case keys', () {
      final data = {
        'id': 'snake-1',
        'name': 'Snake Case Program',
        'path': 'C:/snake/app.exe',
        'use_count': 20,
        'last_used': '2024-07-01',
        'created_at': '2024-02-01',
        'source_dir': 'C:/snake/src',
        'is_tool_library': true,
      };

      final program = ProgramInfo.fromDict(data);

      expect(program.id, 'snake-1');
      expect(program.useCount, 20);
      expect(program.lastUsed, '2024-07-01');
      expect(program.createdAt, '2024-02-01');
      expect(program.sourceDir, 'C:/snake/src');
      expect(program.isToolLibrary, true);
    });

    test('handles missing keys with default values', () {
      final data = <String, dynamic>{
        'id': 'minimal',
        'name': 'Minimal Program',
        'path': 'C:/minimal/app.exe',
      };

      final program = ProgramInfo.fromDict(data);

      expect(program.icon, '');
      expect(program.category, 'all');
      expect(program.description, '');
      expect(program.useCount, 0);
      expect(program.enabled, true);
    });

    test('handles empty map gracefully', () {
      final data = <String, dynamic>{};

      final program = ProgramInfo.fromDict(data);

      expect(program.id, '');
      expect(program.name, '');
      expect(program.path, '');
    });
  });

  group('ProgramInfo.toDict', () {
    test('serializes to JSON map with standard keys', () {
      final program = ProgramInfo(
        id: 'ser-1',
        name: 'Serialize Test',
        path: 'C:/ser/app.exe',
        icon: 'icon.ico',
        category: 'dev',
        description: 'Serialization test',
        useCount: 15,
        lastUsed: '2024-08-01',
        createdAt: '2024-03-01',
        version: '3.0.0',
        sourceDir: 'C:/ser/src',
        enabled: false,
        isToolLibrary: true,
      );

      final map = program.toDict();

      expect(map['id'], 'ser-1');
      expect(map['name'], 'Serialize Test');
      expect(map['path'], 'C:/ser/app.exe');
      expect(map['icon'], 'icon.ico');
      expect(map['category'], 'dev');
      expect(map['description'], 'Serialization test');
      expect(map['useCount'], 15);
      expect(map['lastUsed'], '2024-08-01');
      expect(map['createdAt'], '2024-03-01');
      expect(map['version'], '3.0.0');
      expect(map['sourceDir'], 'C:/ser/src');
      expect(map['enabled'], false);
      expect(map['isToolLibrary'], true);
    });

    test('round-trip serialization preserves data', () {
      final original = ProgramInfo(
        id: 'rt-1',
        name: 'Round Trip',
        path: 'C:/rt/app.exe',
        category: 'test',
        useCount: 42,
        enabled: false,
      );

      final restored = ProgramInfo.fromDict(original.toDict());

      expect(restored, equals(original));
    });
  });

  group('ProgramInfo.copyWith', () {
    test('returns same values when no changes', () {
      final original = ProgramInfo(
        id: 'copy-1',
        name: 'Original',
        path: 'C:/orig/app.exe',
        useCount: 5,
      );

      final copied = original.copyWith();

      expect(copied, equals(original));
    });

    test('updates single field', () {
      final original = ProgramInfo(
        id: 'copy-2',
        name: 'Original',
        path: 'C:/orig/app.exe',
        useCount: 5,
      );

      final updated = original.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.id, original.id);
      expect(updated.path, original.path);
    });

    test('updates multiple fields', () {
      final original = ProgramInfo(
        id: 'copy-3',
        name: 'Original',
        path: 'C:/orig/app.exe',
        useCount: 5,
        enabled: true,
      );

      final updated = original.copyWith(
        useCount: 100,
        enabled: false,
        version: '2.0.0',
      );

      expect(updated.useCount, 100);
      expect(updated.enabled, false);
      expect(updated.version, '2.0.0');
      expect(updated.name, 'Original');
    });
  });

  group('ProgramInfo Equatable', () {
    test('equal programs have same props', () {
      final p1 = ProgramInfo(
        id: 'eq-1',
        name: 'Equal',
        path: 'C:/eq/app.exe',
      );

      final p2 = ProgramInfo(
        id: 'eq-1',
        name: 'Equal',
        path: 'C:/eq/app.exe',
      );

      expect(p1, equals(p2));
    });

    test('different programs are not equal', () {
      final p1 = ProgramInfo(
        id: 'eq-2',
        name: 'Different',
        path: 'C:/eq/app.exe',
      );

      final p2 = ProgramInfo(
        id: 'eq-3',
        name: 'Different',
        path: 'C:/eq/app.exe',
      );

      expect(p1, isNot(equals(p2)));
    });
  });
}