library;

import 'package:equatable/equatable.dart';

class TimeSyncResult extends Equatable {
  final String serverName;
  final String localTime;
  final String serverTime;
  final Duration offset;
  final bool success;
  final String? error;

  const TimeSyncResult({
    required this.serverName,
    required this.localTime,
    required this.serverTime,
    required this.offset,
    this.success = false,
    this.error,
  });

  String get offsetDescription {
    final seconds = offset.inSeconds;
    if (seconds == 0) {
      return '\u65E0\u504F\u79FB';
    } else if (seconds > 0) {
      return '\u670D\u52A1\u5668\u5FEB ${seconds.abs()} \u79D2';
    } else {
      return '\u670D\u52A1\u5668\u6162 ${seconds.abs()} \u79D2';
    }
  }

  TimeSyncResult copyWith({
    String? serverName,
    String? localTime,
    String? serverTime,
    Duration? offset,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return TimeSyncResult(
      serverName: serverName ?? this.serverName,
      localTime: localTime ?? this.localTime,
      serverTime: serverTime ?? this.serverTime,
      offset: offset ?? this.offset,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [serverName, localTime, serverTime, offset, success, error];
}
