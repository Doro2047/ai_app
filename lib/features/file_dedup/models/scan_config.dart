/// 扫描配置模型
///
/// 存储文件查重扫描的配置参数。
library;

/// 扫描配置
class ScanConfig {
  /// 要扫描的目录列表
  final List<String> directories;

  /// 哈希算法类型（md5/sha1/sha256）
  final String hashType;

  /// 最小文件大小（字节），小于此大小的文件跳过
  final int minFileSize;

  /// 最大文件大小（字节），0 表示不限制
  final int maxFileSize;

  /// 是否递归扫描子目录
  final bool recursive;

  /// 是否包含隐藏文件
  final bool includeHidden;

  const ScanConfig({
    this.directories = const [],
    this.hashType = 'md5',
    this.minFileSize = 0,
    this.maxFileSize = 0,
    this.recursive = true,
    this.includeHidden = false,
  });

  /// 有效的哈希算法列表
  static const List<String> validHashTypes = ['md5', 'sha1', 'sha256'];

  /// 哈希算法显示名称映射
  static const Map<String, String> hashTypeLabels = {
    'md5': 'MD5 (推荐)',
    'sha1': 'SHA-1',
    'sha256': 'SHA-256 (最安全)',
  };

  ScanConfig copyWith({
    List<String>? directories,
    String? hashType,
    int? minFileSize,
    int? maxFileSize,
    bool? recursive,
    bool? includeHidden,
  }) {
    return ScanConfig(
      directories: directories ?? this.directories,
      hashType: hashType ?? this.hashType,
      minFileSize: minFileSize ?? this.minFileSize,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      recursive: recursive ?? this.recursive,
      includeHidden: includeHidden ?? this.includeHidden,
    );
  }

  @override
  String toString() => 'ScanConfig(directories: ${directories.length}, hashType: $hashType, minSize: $minFileSize, recursive: $recursive)';
}
