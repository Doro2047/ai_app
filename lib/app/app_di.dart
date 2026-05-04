library;

import 'package:get_it/get_it.dart';

import 'di/core_di.dart';
import 'di/file_tools_di.dart';
import 'di/system_control_di.dart';
import 'di/other_tools_di.dart';
import 'di/toolbox_di.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await registerCoreDependencies(getIt);
  registerFileToolsDependencies(getIt);
  registerSystemControlDependencies(getIt);
  registerOtherToolsDependencies(getIt);
  registerToolboxDependencies(getIt);
}

Future<void> resetDependencies() async {
  await getIt.reset();
}