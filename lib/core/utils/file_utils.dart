import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app_logger.dart';
import 'path_security.dart';

/// 文件操作工具类
/// 使用 path_provider 实现跨平台文件操作，禁止使用硬编码路径
class FileUtils {
  /// 获取应用文档目录
  /// 
  /// 返回应用程序的文档目录路径
  /// 此目录用于存储用户生成的文档，会显示在应用的 iCloud/Drive 等位置
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取临时目录
  /// 
  /// 返回应用的临时目录路径
  /// 此目录中的文件可能会被系统自动清理
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// 获取应用数据目录
  /// 
  /// 返回应用的支持目录路径
  /// 适用于存储不应由用户直接访问的应用内部数据
  static Future<Directory> getAppDataDirectory() async {
    return await getApplicationSupportDirectory();
  }

  /// 获取文件大小
  /// 
  /// 返回文件大小（字节）
  /// 如果文件不存在，返回 -1
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return -1;
    } catch (e, stackTrace) {
      AppLogger.logger.warning('Error getting file size: $filePath', e, stackTrace);
      return -1;
    }
  }

  /// 检查文件是否存在
  /// 
  /// 返回文件是否存在
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e, stackTrace) {
      AppLogger.logger.warning('Error checking file existence: $filePath', e, stackTrace);
      return false;
    }
  }

  /// 创建目录
  /// 
  /// 创建指定路径的目录，recursive 参数控制是否递归创建父目录
  /// [basePath] 可选的基路径，用于安全验证
  static Future<Directory> createDirectory(
    String dirPath, {
    bool recursive = true,
    String? basePath,
  }) async {
    try {
      String safePath = dirPath;
      if (basePath != null) {
        safePath = PathSecurity.normalizeAndValidate(dirPath, basePath);
      }
      
      // 检查非法字符
      if (PathSecurity.hasInvalidChars(safePath)) {
        throw ArgumentError('Path contains invalid characters');
      }
      
      // 检查路径长度
      if (!PathSecurity.isValidLength(safePath)) {
        throw ArgumentError('Path length exceeds limit');
      }
      
      final directory = Directory(safePath);
      return await directory.create(recursive: recursive);
    } catch (e, stackTrace) {
      AppLogger.logger.severe('Error creating directory: $dirPath', e, stackTrace);
      rethrow;
    }
  }

  /// 复制文件
  /// 
  /// 将文件从源路径复制到目标路径
  /// 如果目标文件已存在且 allowOverwrite 为 true，则覆盖
  static Future<File> copyFile(
    String sourcePath,
    String destinationPath, {
    bool allowOverwrite = false,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileSystemException('Source file does not exist', sourcePath);
      }

      final destFile = File(destinationPath);
      if (await destFile.exists() && !allowOverwrite) {
        throw FileSystemException(
          'Destination file already exists',
          destinationPath,
        );
      }

      // 确保目标目录存在
      final destDir = destFile.parent;
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      return await sourceFile.copy(destinationPath);
    } catch (e, stackTrace) {
      AppLogger.logger.severe('Error copying file: $sourcePath -> $destinationPath', e, stackTrace);
      rethrow;
    }
  }

  /// 移动文件
  /// 
  /// 将文件从源路径移动到目标路径
  static Future<File> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileSystemException('Source file does not exist', sourcePath);
      }

      final destFile = File(destinationPath);
      if (await destFile.exists()) {
        throw FileSystemException(
          'Destination file already exists',
          destinationPath,
        );
      }

      // 确保目标目录存在
      final destDir = destFile.parent;
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      return await sourceFile.rename(destinationPath);
    } catch (e, stackTrace) {
      AppLogger.logger.severe('Error moving file: $sourcePath -> $destinationPath', e, stackTrace);
      rethrow;
    }
  }

  /// 删除文件
  /// 
  /// 删除指定路径的文件
  /// 如果 ignoreIfNotExists 为 true，文件不存在时不抛出异常
  static Future<void> deleteFile(
    String filePath, {
    bool ignoreIfNotExists = true,
  }) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      } else if (!ignoreIfNotExists) {
        throw FileSystemException('File does not exist', filePath);
      }
    } catch (e, stackTrace) {
      AppLogger.logger.severe('Error deleting file: $filePath', e, stackTrace);
      rethrow;
    }
  }

  /// 删除目录
  /// 
  /// 删除指定路径的目录
  /// recursive 参数控制是否递归删除子目录和文件
  static Future<void> deleteDirectory(
    String dirPath, {
    bool recursive = true,
    bool ignoreIfNotExists = true,
  }) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        await directory.delete(recursive: recursive);
      } else if (!ignoreIfNotExists) {
        throw FileSystemException('Directory does not exist', dirPath);
      }
    } catch (e, stackTrace) {
      AppLogger.logger.severe('Error deleting directory: $dirPath', e, stackTrace);
      rethrow;
    }
  }

  /// 列出目录中的所有文件
  /// 
  /// 返回目录中的文件列表
  /// recursive 参数控制是否递归列出子目录中的文件
  static Future<List<File>> listFiles(
    String dirPath, {
    bool recursive = false,
  }) async {
    try {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        throw FileSystemException('Directory does not exist', dirPath);
      }

      final List<File> files = [];
      await for (final entity in directory.list(recursive: recursive)) {
        if (entity is File) {
          files.add(entity);
        }
      }
      return files;
    } catch (e, stackTrace) {
      AppLogger.logger.severe('Error listing files: $dirPath', e, stackTrace);
      rethrow;
    }
  }

  /// 获取路径分隔符
  /// 
  /// 返回当前平台的分隔符
  static String getSeparator() {
    return Platform.pathSeparator;
  }

  /// 组合路径
  /// 
  /// 将多个路径部分组合成完整路径
  static String joinPaths(String base, List<String> parts) {
    String path = base;
    for (final part in parts) {
      if (!path.endsWith(Platform.pathSeparator)) {
        path += Platform.pathSeparator;
      }
      path += part;
    }
    return path;
  }
}
