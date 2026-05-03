import 'package:flutter/foundation.dart';

/// 基础状态类
@immutable
abstract class BaseState {
  const BaseState();
}

/// 初始状态
class InitialState extends BaseState {
  const InitialState();
}

/// 加载状态
class LoadingState extends BaseState {
  const LoadingState();
}

/// 成功状态
class SuccessState<T> extends BaseState {
  final T data;

  const SuccessState(this.data);
}

/// 错误状态
class ErrorState extends BaseState {
  final String message;

  const ErrorState(this.message);
}
