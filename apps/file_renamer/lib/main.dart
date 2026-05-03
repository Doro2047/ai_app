import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';

import 'features/file_renamer/bloc/file_renamer_bloc.dart';
import 'features/file_renamer/repositories/file_renamer_repository.dart';
import 'features/file_renamer/views/file_renamer_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<FileRenamerRepository>(() => FileRenamerRepository());
  getIt.registerFactory<FileRenamerBloc>(() => FileRenamerBloc(repository: getIt<FileRenamerRepository>()));

  runApp(const FileRenamerApp());
}

class FileRenamerApp extends StatelessWidget {
  const FileRenamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => getIt<ThemeBloc>(),
      child: MaterialApp(
        title: 'File Renamer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildThemeData(SkinType.defaultLight),
        home: const FileRenamerPage(),
      ),
    );
  }
}
