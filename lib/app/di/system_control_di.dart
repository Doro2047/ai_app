import 'package:get_it/get_it.dart';

import '../../features/system_control/repositories/system_control_repository.dart';
import '../../features/system_control/repositories/power_control_repository.dart';
import '../../features/system_control/repositories/network_control_repository.dart';
import '../../features/system_control/bloc/system_control_bloc.dart';

/// 系统控制模块依赖注册
void registerSystemControlDependencies(GetIt getIt) {
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
}