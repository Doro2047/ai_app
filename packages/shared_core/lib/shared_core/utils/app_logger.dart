import 'package:logging/logging.dart';

/// 应用日志工具
class AppLogger {
  AppLogger._();

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  static Logger get logger => Logger('AppLogger');
}
