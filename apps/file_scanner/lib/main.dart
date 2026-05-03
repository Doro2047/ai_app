import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_core/shared_core.dart';

import 'injection.dart';
import 'features/file_scanner/views/file_scanner_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await setupDependencies();
  runApp(const FileScannerApp());
}

class FileScannerApp extends StatelessWidget {
  const FileScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => getIt<ThemeBloc>(),
      child: MaterialApp(
        title: 'File Scanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildThemeData(SkinType.defaultLight),
        home: const FileScannerPage(),
      ),
    );
  }
}
