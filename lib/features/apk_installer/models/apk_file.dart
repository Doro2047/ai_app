/// APK 文件模型
///
/// 表示一个待安装的 APK 文件。
library;

import 'package:equatable/equatable.dart';

/// APK 文件信息
class ApkFile extends Equatable {
  /// 文件路径
  final String path;

  /// 文件名
  final String name;

  /// 包名 (可选)
  final String? packageName;

  /// 版本号 (可选)
  final String? version;

  /// 文件大小 (字节)
  final int size;

  /// 是否选中
  final bool selected;

  const ApkFile({
    required this.path,
    required this.name,
    this.packageName,
    this.version,
    this.size = 0,
    this.selected = true,
  });

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// 显示名称（优先使用包名）
  String get displayName => packageName ?? name;

  /// 复制并修改选中状态
  ApkFile copyWith({
    String? path,
    String? name,
    String? packageName,
    String? version,
    int? size,
    bool? selected,
  }) {
    return ApkFile(
      path: path ?? this.path,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      size: size ?? this.size,
      selected: selected ?? this.selected,
    );
  }

  Map<String, dynamic> toDict() {
    return {
      'path': path,
      'name': name,
      'packageName': packageName,
      'version': version,
      'size': size,
      'selected': selected,
    };
  }

  factory ApkFile.fromDict(Map<String, dynamic> data) {
    return ApkFile(
      path: data['path'] as String,
      name: data['name'] as String,
      packageName: data['packageName'] as String?,
      version: data['version'] as String?,
      size: data['size'] as int? ?? 0,
      selected: data['selected'] as bool? ?? true,
    );
  }

  /// 创建简单实例（无包信息）
  factory ApkFile.fromPath(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    return ApkFile(path: path, name: name);
  }

  @override
  List<Object?> get props => [
        path,
        name,
        packageName,
        version,
        size,
        selected,
      ];
}
