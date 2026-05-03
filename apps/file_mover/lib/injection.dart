import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';
import 'features/file_mover/bloc/file_mover_bloc.dart';
import 'features/file_mover/repositories/file_mover_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<FileMoverRepository>(() => FileMoverRepository());
  getIt.registerFactory<FileMoverBloc>(() => FileMoverBloc(repository: getIt<FileMoverRepository>()));
}
