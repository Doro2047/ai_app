import 'package:get_it/get_it.dart';

import '../../features/file_dedup/repositories/file_dedup_repository.dart';
import '../../features/file_dedup/bloc/file_dedup_bloc.dart';
import '../../features/extension_changer/repositories/extension_changer_repository.dart';
import '../../features/extension_changer/bloc/extension_changer_bloc.dart';
import '../../features/file_mover/repositories/file_mover_repository.dart';
import '../../features/file_mover/bloc/file_mover_bloc.dart';
import '../../features/file_scanner/repositories/file_scanner_repository.dart';
import '../../features/file_scanner/bloc/file_scanner_bloc.dart';
import '../../features/file_renamer/repositories/file_renamer_repository.dart';
import '../../features/file_renamer/bloc/file_renamer_bloc.dart';

/// 文件工具模块依赖注册
void registerFileToolsDependencies(GetIt getIt) {
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