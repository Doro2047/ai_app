import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';

import 'features/file_dedup/bloc/file_dedup_bloc.dart';
import 'features/file_dedup/repositories/file_dedup_repository.dart';
import 'features/file_dedup/views/file_dedup_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<FileDedupRepository>(() => FileDedupRepository());
  getIt.registerFactory<FileDedupBloc>(() => FileDedupBloc(repository: getIt<FileDedupRepository>()));

  runApp(const FileDedupApp());
}

class FileDedupApp extends StatelessWidget {
  const FileDedupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => getIt<ThemeBloc>(),
      child: MaterialApp(
        title: 'File Dedup Cleaner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildThemeData(SkinType.defaultLight),
        home: const FileDedupPage(),
      ),
    );
  }
}
