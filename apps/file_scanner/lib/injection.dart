import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';
import 'features/file_scanner/bloc/file_scanner_bloc.dart';
import 'features/file_scanner/repositories/file_scanner_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<FileScannerRepository>(() => FileScannerRepository());
  getIt.registerFactory<FileScannerBloc>(() => FileScannerBloc(repository: getIt<FileScannerRepository>()));
}
