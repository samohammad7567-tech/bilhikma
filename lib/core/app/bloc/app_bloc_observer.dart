import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  static const String _logName = 'bloc';
  static const int _maxDetailsLength = 2000;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);

    _log('CREATE', '${bloc.runtimeType} created');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);

    _log(
      'EVENT',
      '${bloc.runtimeType} received ${event.runtimeType}',
      details: _format(event),
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);

    _log(
      'TRANSITION',
      '${bloc.runtimeType}: '
          '${transition.currentState.runtimeType} -> '
          '${transition.nextState.runtimeType}',
      details:
          'Event: ${_format(transition.event)}\n'
          'Current: ${_format(transition.currentState)}\n'
          'Next: ${_format(transition.nextState)}',
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    if (change.currentState == change.nextState) {
      return;
    }

    _log(
      'CHANGE',
      '${bloc.runtimeType}: '
          '${change.currentState.runtimeType} -> '
          '${change.nextState.runtimeType}',
      details:
          'Current: ${change.currentState}\n'
          'Next: ${change.nextState}',
    );
  }

  @override
  void onDone(
    Bloc<dynamic, dynamic> bloc,
    Object? event, [
    Object? result,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    super.onDone(bloc, event, result, stackTrace);

    if (error != null) {
      _log(
        'DONE WITH ERROR',
        '${bloc.runtimeType} failed while handling '
            '${event.runtimeType}',
        details: error.toString(),
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    _log('DONE', '${bloc.runtimeType} completed ${event.runtimeType}');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    _log('CLOSE', '${bloc.runtimeType} closed');

    super.onClose(bloc);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _log(
      'ERROR',
      '${bloc.runtimeType} encountered an error',
      details: error.toString(),
      error: error,
      stackTrace: stackTrace,
    );

    super.onError(bloc, error, stackTrace);
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _format(Object? value) {
    if (value == null) return 'null';

    final String output = value.toString();

    if (output.length > _maxDetailsLength) {
      return '${output.substring(0, _maxDetailsLength)}... [TRUNCATED]';
    }

    return output;
  }

  // ---------------------------------------------------------------------------
  // Logging
  // ---------------------------------------------------------------------------

  void _log(
    String action,
    String message, {
    String? details,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    developer.log(
      '[$action] $message'
      '${details == null ? '' : '\n$details'}',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
