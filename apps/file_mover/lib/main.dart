import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';

import 'injection.dart';
import 'features/file_mover/views/file_mover_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  setupDependencies();
  runApp(const FileMoverApp());
}

class FileMoverApp extends StatelessWidget {
  const FileMoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => getIt<ThemeBloc>(),
      child: MaterialApp(
        title: 'File Mover',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildThemeData(SkinType.defaultLight),
        home: const FileMoverPage(),
      ),
    );
  }
}
