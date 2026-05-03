import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';
import 'features/system_control/bloc/system_control_bloc.dart';
import 'features/system_control/repositories/system_control_repository.dart';
import 'features/system_control/repositories/power_control_repository.dart';
import 'features/system_control/repositories/network_control_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<SystemControlRepository>(() => SystemControlRepository());
  getIt.registerLazySingleton<PowerControlRepository>(() => PowerControlRepository());
  getIt.registerLazySingleton<NetworkControlRepository>(() => NetworkControlRepository());
  getIt.registerFactory<SystemControlBloc>(() => SystemControlBloc(
    systemControlRepo: getIt<SystemControlRepository>(),
    networkRepo: getIt<NetworkControlRepository>(),
    powerRepo: getIt<PowerControlRepository>(),
  ));
}
