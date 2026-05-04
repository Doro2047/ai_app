import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../core/storage/data_migrator.dart';
import '../../shared/bloc/theme_bloc.dart';
import '../../shared/bloc/locale_bloc.dart';

/// 核心模块依赖注册
Future<void> registerCoreDependencies(GetIt getIt) async {
  getIt.registerLazySingletonAsync<StorageService>(() async {
    return await StorageService.init();
  });

  getIt.registerLazySingletonAsync<DataMigrator>(() async {
    final migrator = DataMigrator();
    await migrator.init();
    return migrator;
  });

  getIt.registerLazySingleton<ApiClient>(() {
    final client = ApiClient();
    client.init(baseUrl: AppConstants.apiBaseUrl);
    return client;
  });

  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<LocaleBloc>(() {
    final bloc = LocaleBloc();
    bloc.init();
    return bloc;
  });
}