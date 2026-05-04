import 'package:get_it/get_it.dart';

import '../../features/image_classifier/repositories/image_classifier_repository.dart';
import '../../features/image_classifier/bloc/bloc.dart';
import '../../features/search/repositories/search_repository.dart';
import '../../features/toolbox/repositories/program_repository.dart';
import '../../features/toolbox/repositories/hardware_repository.dart';
import '../../features/toolbox/repositories/config_repository.dart';
import '../../features/toolbox/repositories/custom_info_repository.dart';

/// 工具箱模块依赖注册
void registerToolboxDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ImageClassifierRepository>(() => ImageClassifierRepository());
  getIt.registerFactory<ImageClassifierBloc>(() {
    final bloc = ImageClassifierBloc(repository: getIt<ImageClassifierRepository>());
    bloc.init();
    return bloc;
  });

  getIt.registerLazySingleton<SearchRepository>(() => SearchRepository());

  getIt.registerLazySingletonAsync<ProgramRepository>(() async {
    final repo = ProgramRepository();
    await repo.init();
    await repo.initDefaults();
    return repo;
  });
  getIt.registerLazySingleton<HardwareRepository>(() => HardwareRepository());
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
}