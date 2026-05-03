library;

import 'package:get_it/get_it.dart';

import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../core/storage/data_migrator.dart';
import '../shared/bloc/theme_bloc.dart';
import '../shared/bloc/locale_bloc.dart';
import '../features/toolbox/repositories/program_repository.dart';
import '../features/toolbox/repositories/hardware_repository.dart';
import '../features/toolbox/repositories/config_repository.dart';
import '../features/toolbox/repositories/custom_info_repository.dart';
import '../features/file_dedup/repositories/file_dedup_repository.dart';
import '../features/file_dedup/bloc/file_dedup_bloc.dart';
import '../features/extension_changer/repositories/extension_changer_repository.dart';
import '../features/extension_changer/bloc/extension_changer_bloc.dart';
import '../features/file_mover/repositories/file_mover_repository.dart';
import '../features/file_mover/bloc/file_mover_bloc.dart';
import '../features/system_control/repositories/system_control_repository.dart';
import '../features/system_control/repositories/power_control_repository.dart';
import '../features/system_control/repositories/network_control_repository.dart';
import '../features/system_control/bloc/system_control_bloc.dart';
import '../features/apk_installer/repositories/apk_installer_repository.dart';
import '../features/apk_installer/repositories/adb_client.dart';
import '../features/apk_installer/bloc/apk_installer_bloc.dart';
import '../features/bookmark_manager/repositories/bookmark_repository.dart';
import '../features/bookmark_manager/repositories/link_validator_repository.dart';
import '../features/bookmark_manager/repositories/category_repository.dart';
import '../features/bookmark_manager/bloc/bookmark_bloc.dart';
import '../features/bookmark_manager/bloc/bookmark_manager_bloc.dart';
import '../features/search/repositories/search_repository.dart';
import '../features/image_classifier/repositories/image_classifier_repository.dart';
import '../features/image_classifier/bloc/bloc.dart';
import '../features/file_scanner/repositories/file_scanner_repository.dart';
import '../features/file_scanner/bloc/file_scanner_bloc.dart';
import '../features/file_renamer/repositories/file_renamer_repository.dart';
import '../features/file_renamer/bloc/file_renamer_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
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

  getIt.registerLazySingletonAsync<ProgramRepository>(() async {
    final repo = ProgramRepository();
    await repo.init();
    await repo.initDefaults();
    return repo;
  });

  getIt.registerLazySingleton<HardwareRepository>(() {
    return HardwareRepository();
  });

  getIt.registerLazySingletonAsync<ConfigRepository>(() async {
    final repo = ConfigRepository();
    await repo.init();
    return repo;
  });

  getIt.registerLazySingletonAsync<CustomInfoRepository>(() async {
    final repo = CustomInfoRepository();
    await repo.init();
    return repo;
  });

  getIt.registerLazySingleton<FileDedupRepository>(() => FileDedupRepository());
  getIt.registerFactory<FileDedupBloc>(() {
    final bloc = FileDedupBloc(repository: getIt<FileDedupRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<ExtensionChangerRepository>(() => ExtensionChangerRepository());
  getIt.registerFactory<ExtensionChangerBloc>(() {
    final bloc = ExtensionChangerBloc(repository: getIt<ExtensionChangerRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<FileMoverRepository>(() => FileMoverRepository());
  getIt.registerFactory<FileMoverBloc>(() {
    final bloc = FileMoverBloc(repository: getIt<FileMoverRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<SystemControlRepository>(() => SystemControlRepository());
  getIt.registerLazySingleton<PowerControlRepository>(() => PowerControlRepository());
  getIt.registerLazySingleton<NetworkControlRepository>(() => NetworkControlRepository());
  getIt.registerFactory<SystemControlBloc>(() {
    final bloc = SystemControlBloc(
      systemControlRepo: getIt<SystemControlRepository>(),
      networkRepo: getIt<NetworkControlRepository>(),
      powerRepo: getIt<PowerControlRepository>(),
    );
    bloc.init();
    return bloc;
  });

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

  getIt.registerLazySingleton<SearchRepository>(() => SearchRepository());

  getIt.registerLazySingleton<ImageClassifierRepository>(() => ImageClassifierRepository());
  getIt.registerFactory<ImageClassifierBloc>(() {
    final bloc = ImageClassifierBloc(repository: getIt<ImageClassifierRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<FileScannerRepository>(() => FileScannerRepository());
  getIt.registerFactory<FileScannerBloc>(() {
    final bloc = FileScannerBloc(repository: getIt<FileScannerRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<FileRenamerRepository>(() => FileRenamerRepository());
  getIt.registerFactory<FileRenamerBloc>(() {
    final bloc = FileRenamerBloc(repository: getIt<FileRenamerRepository>());
    bloc.init();
    return bloc;
  });
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
