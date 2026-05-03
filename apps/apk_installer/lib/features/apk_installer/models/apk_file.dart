library;

import 'package:equatable/equatable.dart';

class ApkFile extends Equatable {
  final String path;
  final String name;
  final String? packageName;
  final String? version;
  final int size;
  final bool selected;

  const ApkFile({
    required this.path,
    required this.name,
    this.packageName,
    this.version,
    this.size = 0,
    this.selected = true,
  });

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get displayName => packageName ?? name;

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
