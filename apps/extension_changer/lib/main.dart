import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';

import 'features/extension_changer/bloc/extension_changer_bloc.dart';
import 'features/extension_changer/repositories/extension_changer_repository.dart';
import 'features/extension_changer/views/extension_changer_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<ExtensionChangerRepository>(() => ExtensionChangerRepository());
  getIt.registerFactory<ExtensionChangerBloc>(() => ExtensionChangerBloc(repository: getIt<ExtensionChangerRepository>()));

  runApp(const ExtensionChangerApp());
}

class ExtensionChangerApp extends StatelessWidget {
  const ExtensionChangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => getIt<ThemeBloc>(),
      child: MaterialApp(
        title: 'Extension Changer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildThemeData(SkinType.defaultLight),
        home: const ExtensionChangerPage(),
      ),
    );
  }
}
