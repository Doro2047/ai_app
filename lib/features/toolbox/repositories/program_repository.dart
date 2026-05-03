/// 程序仓库
///
/// 使用 Hive 存储程序数据，提供 CRUD 操作、分类查询、使用计数等功能。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/program.dart';

/// Hive Box 名称
const String _programBoxName = 'toolbox_programs';

/// 排序方式
enum ProgramSortBy {
  /// 按名称
  name,

  /// 按使用次数
  useCount,

  /// 按最后使用时间
  lastUsed,

  /// 按创建时间
  createdAt,
}

/// 程序仓库
class ProgramRepository {
  late Box _box;
  final _uuid = const Uuid();

  /// 初始化仓库
  Future<void> init() async {
    _box = await Hive.openBox(_programBoxName);
  }

  /// 添加程序
  Future<ProgramInfo> add(ProgramInfo program) async {
    final newProgram = program.id.isEmpty
        ? program.copyWith(id: _uuid.v4(), createdAt: DateTime.now().toIso8601String())
        : program;
    await _box.put(newProgram.id, newProgram.toDict());
    return newProgram;
  }

  /// 更新程序
  Future<void> update(ProgramInfo program) async {
    await _box.put(program.id, program.toDict());
  }

  /// 删除程序
  Future<void> remove(String programId) async {
    await _box.delete(programId);
  }

  /// 获取单个程序
  ProgramInfo? get(String programId) {
    final data = _box.get(programId);
    if (data == null) return null;
    return ProgramInfo.fromDict(Map<String, dynamic>.from(data as Map));
  }

  /// 获取所有程序
  List<ProgramInfo> getAll() {
    return _box.values.map((data) {
      return ProgramInfo.fromDict(Map<String, dynamic>.from(data as Map));
    }).toList();
  }

  /// 按分类查询程序
  List<ProgramInfo> getProgramsByCategory(
    String categoryId, {
    String searchText = '',
    ProgramSortBy sortBy = ProgramSortBy.name,
  }) {
    var programs = getAll();

    // 按分类筛选
    if (categoryId != 'all') {
      programs = programs.where((p) => p.category == categoryId).toList();
    }

    // 搜索过滤
    if (searchText.isNotEmpty) {
      final query = searchText.toLowerCase();
      programs = programs.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.path.toLowerCase().contains(query);
      }).toList();
    }

    // 排序
    switch (sortBy) {
      case ProgramSortBy.name:
        programs.sort((a, b) => a.name.compareTo(b.name));
      case ProgramSortBy.useCount:
        programs.sort((a, b) => b.useCount.compareTo(a.useCount));
      case ProgramSortBy.lastUsed:
        programs.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      case ProgramSortBy.createdAt:
        programs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return programs;
  }

  /// 递增使用次数
  Future<void> incrementUseCount(String programId) async {
    final program = get(programId);
    if (program == null) return;
    final updated = program.copyWith(
      useCount: program.useCount + 1,
      lastUsed: DateTime.now().toIso8601String(),
    );
    await update(updated);
  }

  /// 清理无效程序（路径不存在的程序）
  Future<List<String>> cleanInvalidPrograms() async {
    final allPrograms = getAll();
    final invalidIds = <String>[];

    for (final program in allPrograms) {
      if (program.path.isNotEmpty && !program.isToolLibrary) {
        try {
          final file = File(program.path);
          if (!await file.exists()) {
            invalidIds.add(program.id);
          }
        } catch (e) {
          debugPrint('检查程序路径失败: ${program.path}, 错误: $e');
          invalidIds.add(program.id);
        }
      }
    }

    for (final id in invalidIds) {
      await remove(id);
    }

    return invalidIds;
  }

  /// 扫描目录中的程序
  Future<List<ProgramInfo>> scanDirectory(String directory) async {
    final foundPrograms = <ProgramInfo>[];
    final dir = Directory(directory);

    if (!await dir.exists()) return foundPrograms;

    // 获取现有程序路径集合，避免重复添加
    final existingPaths = getAll().map((p) => p.path).toSet();

    try {
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          final ext = entity.path.toLowerCase();
          if (ext.endsWith('.exe') || ext.endsWith('.lnk') || ext.endsWith('.bat')) {
            if (!existingPaths.contains(entity.path)) {
              final name = entity.path
                  .split(Platform.pathSeparator)
                  .last
                  .replaceAll(RegExp(r'\.(exe|lnk|bat)$', caseSensitive: false), '');
              foundPrograms.add(ProgramInfo(
                id: _uuid.v4(),
                name: name,
                path: entity.path,
                category: 'other',
                createdAt: DateTime.now().toIso8601String(),
              ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('扫描目录失败: $e');
    }

    return foundPrograms;
  }

  /// 初始化默认分类和工具库程序
  Future<void> initDefaults() async {
    final existing = getAll();
    if (existing.any((p) => p.isToolLibrary)) return;

    // 添加工具库默认程序
    final toolLibraryPrograms = <ProgramInfo>[
      ProgramInfo(
        id: _uuid.v4(),
        name: '计算器',
        path: 'calc.exe',
        icon: 'calculate',
        category: 'system',
        description: 'Windows 计算器',
        isToolLibrary: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      ProgramInfo(
        id: _uuid.v4(),
        name: '记事本',
        path: 'notepad.exe',
        icon: 'edit_note',
        category: 'file',
        description: 'Windows 记事本',
        isToolLibrary: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      ProgramInfo(
        id: _uuid.v4(),
        name: '画图',
        path: 'mspaint.exe',
        icon: 'brush',
        category: 'media',
        description: 'Windows 画图',
        isToolLibrary: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      ProgramInfo(
        id: _uuid.v4(),
        name: '命令提示符',
        path: 'cmd.exe',
        icon: 'terminal',
        category: 'system',
        description: 'Windows 命令提示符',
        isToolLibrary: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      ProgramInfo(
        id: _uuid.v4(),
        name: '任务管理器',
        path: 'taskmgr.exe',
        icon: 'monitor_heart',
        category: 'system',
        description: 'Windows 任务管理器',
        isToolLibrary: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      ProgramInfo(
        id: _uuid.v4(),
        name: '控制面板',
        path: 'control.exe',
        icon: 'tune',
        category: 'system',
        description: 'Windows 控制面板',
        isToolLibrary: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    for (final program in toolLibraryPrograms) {
      await add(program);
    }
  }

  /// 关闭仓库
  Future<void> close() async {
    await _box.close();
  }
}
