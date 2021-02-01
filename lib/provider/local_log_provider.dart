import 'dart:async';

import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/utils/permissions.dart';

class LogsProvider extends ChangeNotifier {
  static LogsProvider provider;
  StreamController<Iterable<CallLogEntry>> _logsCont =
      StreamController<Iterable<CallLogEntry>>.broadcast();
  StreamSubscription<Iterable<CallLogEntry>> _logsSub;
  List<CallLogEntry> _logs = [];

  static Future<LogsProvider> getInstance() async {
    if (provider == null) {
      LogsProvider placeholder = LogsProvider();
      await placeholder.init();
      provider = placeholder;
    }
    return provider;
  }

  Future<void> init([bool topause = false]) async {
    if (await Permissions.contactPermissionsGranted()) {
      if (_logsSub != null)
        resume();
      else {
        _logsSub = getLocalLogs().listen((event) {
          _logs = event.toList();
          // print(contactList);
          _logsCont.add(event);
          if (topause) pause();
        });
        print('STARTED');
      }
    }
    _logsCont.add(null);
  }

  void pause() {
    if (_logsSub != null) {
      _logsSub.pause();
      print('PAUSED');
    }
  }

  void resume() {
    _logsSub.resume();
    print('RESUMED');
  }

  void close() {
    if (_logsSub != null) {
      _logsCont.close();
      _logsSub.cancel();
      print('CLOSED');
    }
  }

  Stream<Iterable<CallLogEntry>> getLocalLogs() async* {
    try {
      if (await Permissions.contactPermissionsGranted()) {
        while (true) {
          await Future.delayed(Duration(milliseconds: 500));
          yield await CallLog.get();
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  StreamController<Iterable<CallLogEntry>> get controller => _logsCont;
  List<CallLogEntry> get contactList => _logs;
}
