import 'package:get_it/get_it.dart';
import 'package:shared_core/shared_core.dart';
import 'features/bookmark_manager/bloc/bookmark_bloc.dart';
import 'features/bookmark_manager/bloc/bookmark_manager_bloc.dart';
import 'features/bookmark_manager/repositories/bookmark_repository.dart';
import 'features/bookmark_manager/repositories/link_validator_repository.dart';
import 'features/bookmark_manager/repositories/category_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<ThemeBloc>(() {
    final bloc = ThemeBloc();
    bloc.init();
    return bloc;
  });
  getIt.registerLazySingleton<BookmarkRepository>(() => BookmarkRepository());
  getIt.registerLazySingleton<LinkValidatorRepository>(() => LinkValidatorRepository());
  getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepository());
  getIt.registerFactory<BookmarkManagerBloc>(() => BookmarkManagerBloc(
    bookmarkRepository: getIt<BookmarkRepository>(),
    linkValidatorRepository: getIt<LinkValidatorRepository>(),
    categoryRepository: getIt<CategoryRepository>(),
  ));
  getIt.registerFactory<BookmarkBloc>(() => BookmarkBloc(repository: getIt<BookmarkRepository>()));
}
