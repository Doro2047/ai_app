import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';

import 'features/apk_installer/bloc/apk_installer_bloc.dart';
import 'features/apk_installer/repositories/apk_installer_repository.dart';
import 'features/apk_installer/repositories/adb_client.dart';
import 'features/apk_installer/views/apk_installer_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  getIt.registerLazySingleton<AdbClient>(() => AdbClient());
  getIt.registerLazySingleton<ApkInstallerRepository>(
    () => ApkInstallerRepository(adbClient: getIt<AdbClient>()),
  );
  getIt.registerFactory<ApkInstallerBloc>(
    () => ApkInstallerBloc(repository: getIt<ApkInstallerRepository>()),
  );

  runApp(const ApkInstallerApp());
}

class ApkInstallerApp extends StatelessWidget {
  const ApkInstallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APK Batch Installer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildThemeData(SkinType.defaultLight),
      home: const ApkInstallerPage(),
    );
  }
}
