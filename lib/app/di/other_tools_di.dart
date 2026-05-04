import 'package:get_it/get_it.dart';

import '../../features/apk_installer/repositories/adb_client.dart';
import '../../features/apk_installer/repositories/apk_installer_repository.dart';
import '../../features/apk_installer/bloc/apk_installer_bloc.dart';
import '../../features/bookmark_manager/repositories/bookmark_repository.dart';
import '../../features/bookmark_manager/repositories/link_validator_repository.dart';
import '../../features/bookmark_manager/repositories/category_repository.dart';
import '../../features/bookmark_manager/bloc/bookmark_bloc.dart';
import '../../features/bookmark_manager/bloc/bookmark_manager_bloc.dart';

/// 其他工具模块依赖注册
void registerOtherToolsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AdbClient>(() => AdbClient());
  getIt.registerLazySingleton<ApkInstallerRepository>(() => ApkInstallerRepository(adbClient: getIt<AdbClient>()));
  getIt.registerFactory<ApkInstallerBloc>(() {
    final bloc = ApkInstallerBloc(repository: getIt<ApkInstallerRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<BookmarkRepository>(() => BookmarkRepository());
  getIt.registerLazySingleton<LinkValidatorRepository>(() => LinkValidatorRepository());
  getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepository());
  getIt.registerFactory<BookmarkManagerBloc>(() {
    final bloc = BookmarkManagerBloc(
      bookmarkRepository: getIt<BookmarkRepository>(),
      linkValidatorRepository: getIt<LinkValidatorRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
    );
    bloc.init();
    return bloc;
  });
  getIt.registerFactory<BookmarkBloc>(() {
    final bloc = BookmarkBloc(repository: getIt<BookmarkRepository>());
    bloc.init();
    return bloc;
  });
}