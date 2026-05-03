import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLogger.init();

  Bloc.observer = AppBlocObserver();

  await Hive.initFlutter();

  await setupDependencies();
  await getIt.allReady();

  Logger('Main').info('应用启动');

  runApp(const AiApp());
}
