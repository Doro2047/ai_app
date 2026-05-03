import 'dart:async';
import 'dart:isolate';

class IsolateHelper {
  IsolateHelper._();

  static Future<T> run<T, P>(
    Future<T> Function(P) function,
    P parameter,
  ) async {
    final completer = Completer<T>();
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _isolateEntry<T, P>,
      _IsolateConfig<T, P>(
        function: function,
        parameter: parameter,
        sendPort: receivePort.sendPort,
      ),
    );

    receivePort.listen((message) {
      if (message is _IsolateSuccess<T>) {
        completer.complete(message.result);
        receivePort.close();
      } else if (message is _IsolateError) {
        completer.completeError(
          IsolateException(message.message, message.stackTrace),
        );
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<T> runWithProgress<T, P>(
    Future<T> Function(P, void Function(double)) function,
    P parameter,
    void Function(double) onProgress,
  ) async {
    final completer = Completer<T>();
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _isolateProgressEntry<T, P>,
      _IsolateProgressConfig<T, P>(
        function: function,
        parameter: parameter,
        sendPort: receivePort.sendPort,
      ),
    );

    receivePort.listen((message) {
      if (message is _IsolateProgress) {
        onProgress(message.progress);
      } else if (message is _IsolateSuccess<T>) {
        completer.complete(message.result);
        receivePort.close();
      } else if (message is _IsolateError) {
        completer.completeError(
          IsolateException(message.message, message.stackTrace),
        );
        receivePort.close();
      }
    });

    return completer.future;
  }

  static void _isolateEntry<T, P>(_IsolateConfig<T, P> config) async {
    try {
      final result = await config.function(config.parameter);
      config.sendPort.send(_IsolateSuccess<T>(result));
    } catch (e, stackTrace) {
      config.sendPort.send(_IsolateError(
        e.toString(),
        stackTrace.toString(),
      ));
    }
  }

  static void _isolateProgressEntry<T, P>(
    _IsolateProgressConfig<T, P> config,
  ) async {
    try {
      final result = await config.function(config.parameter, (progress) {
        config.sendPort.send(_IsolateProgress(progress));
      });
      config.sendPort.send(_IsolateSuccess<T>(result));
    } catch (e, stackTrace) {
      config.sendPort.send(_IsolateError(
        e.toString(),
        stackTrace.toString(),
      ));
    }
  }
}

class IsolateException implements Exception {
  final String message;
  final String? stackTrace;

  const IsolateException(this.message, [this.stackTrace]);

  @override
  String toString() => 'IsolateException: $message';
}

class _IsolateConfig<T, P> {
  final Future<T> Function(P) function;
  final P parameter;
  final SendPort sendPort;

  const _IsolateConfig({
    required this.function,
    required this.parameter,
    required this.sendPort,
  });
}

class _IsolateProgressConfig<T, P> {
  final Future<T> Function(P, void Function(double)) function;
  final P parameter;
  final SendPort sendPort;

  const _IsolateProgressConfig({
    required this.function,
    required this.parameter,
    required this.sendPort,
  });
}

class _IsolateSuccess<T> {
  final T result;
  const _IsolateSuccess(this.result);
}

class _IsolateError {
  final String message;
  final String stackTrace;
  const _IsolateError(this.message, this.stackTrace);
}

class _IsolateProgress {
  final double progress;
  const _IsolateProgress(this.progress);
}
