import 'package:permission_handler/permission_handler.dart' as ph;

/// 权限管理工具类
/// 使用 permission_handler 包实现跨平台权限管理
class PermissionUtils {
  /// 请求存储权限
  /// 
  /// Android: 请求 MANAGE_EXTERNAL_STORAGE 或 READ/WRITE_EXTERNAL_STORAGE
  /// iOS: 请求 Photos 权限
  /// 返回权限授予状态
  static Future<bool> requestStoragePermission() async {
    ph.PermissionStatus status;
    
    if (await ph.Permission.manageExternalStorage.isRestricted) {
      status = await ph.Permission.manageExternalStorage.request();
    } else if (await ph.Permission.storage.isRestricted) {
      status = await ph.Permission.storage.request();
    } else {
      status = await ph.Permission.photos.request();
    }
    
    return status.isGranted;
  }

  /// 请求相机权限
  /// 
  /// 返回权限授予状态
  static Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  /// 请求位置权限
  /// 
  /// 返回权限授予状态
  static Future<bool> requestLocationPermission() async {
    final status = await ph.Permission.location.request();
    return status.isGranted;
  }

  /// 请求麦克风权限
  /// 
  /// 返回权限授予状态
  static Future<bool> requestMicrophonePermission() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  /// 请求通知权限
  /// 
  /// 返回权限授予状态
  static Future<bool> requestNotificationPermission() async {
    final status = await ph.Permission.notification.request();
    return status.isGranted;
  }

  /// 请求联系人权限
  /// 
  /// 返回权限授予状态
  static Future<bool> requestContactsPermission() async {
    final status = await ph.Permission.contacts.request();
    return status.isGranted;
  }

  /// 检查权限状态
  /// 
  /// 返回指定权限的当前状态
  static Future<ph.PermissionStatus> checkPermissionStatus(
    ph.Permission permission,
  ) async {
    return await permission.status;
  }

  /// 检查存储权限状态
  static Future<bool> isStorageGranted() async {
    return await ph.Permission.storage.isGranted ||
           await ph.Permission.manageExternalStorage.isGranted ||
           await ph.Permission.photos.isGranted;
  }

  /// 检查相机权限状态
  static Future<bool> isCameraGranted() async {
    return await ph.Permission.camera.isGranted;
  }

  /// 检查位置权限状态
  static Future<bool> isLocationGranted() async {
    return await ph.Permission.location.isGranted;
  }

  /// 打开应用设置
  /// 
  /// 跳转到系统设置中的应用权限设置页面
  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  /// 批量请求多个权限
  /// 
  /// 返回权限请求结果映射
  static Future<Map<ph.Permission, ph.PermissionStatus>> requestPermissions(
    List<ph.Permission> permissions,
  ) async {
        final results = await Future.wait(permissions.map((p) => p.request()));
    final statusMap = <ph.Permission, ph.PermissionStatus>{};
    for (var i = 0; i < permissions.length; i++) {
      statusMap[permissions[i]] = results[i];
    }
    return statusMap;
  }

  /// 检查是否有某个权限被永久拒绝
  /// 
  /// 返回是否被永久拒绝
  static Future<bool> isPermanentlyDenied(ph.Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  /// 检查存储权限是否被永久拒绝
  static Future<bool> isStoragePermanentlyDenied() async {
    return await ph.Permission.storage.isPermanentlyDenied ||
           await ph.Permission.manageExternalStorage.isPermanentlyDenied;
  }

  /// 检查相机权限是否被永久拒绝
  static Future<bool> isCameraPermanentlyDenied() async {
    return await ph.Permission.camera.isPermanentlyDenied;
  }

  /// 获取所有被拒绝的权限
  /// 
  /// 返回被拒绝的权限列表
  static Future<List<ph.Permission>> getDeniedPermissions(
    List<ph.Permission> permissions,
  ) async {
    final List<ph.Permission> denied = [];
    for (final permission in permissions) {
      if (await permission.isDenied) {
        denied.add(permission);
      }
    }
    return denied;
  }

  /// 获取所有已授予的权限
  /// 
  /// 返回已授予的权限列表
  static Future<List<ph.Permission>> getGrantedPermissions(
    List<ph.Permission> permissions,
  ) async {
    final List<ph.Permission> granted = [];
    for (final permission in permissions) {
      if (await permission.isGranted) {
        granted.add(permission);
      }
    }
    return granted;
  }

  /// 检查是否需要显示权限请求理由
  /// 
  /// Android 特有功能，用于向用户解释为什么需要该权限
  static Future<bool> shouldShowRequestPermissionRationale(
    ph.Permission permission,
  ) async {
    return await permission.shouldShowRequestRationale;
  }
}

