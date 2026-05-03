import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FeatureBlocBase<Event, State> extends Bloc<Event, State> {
  FeatureBlocBase(super.initialState);

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _isInitialized = true;
  }
}
