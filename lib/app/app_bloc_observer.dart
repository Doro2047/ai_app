import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/errors/error_handler.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    ErrorHandler.handleError(error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }
}
