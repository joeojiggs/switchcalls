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
    if (_logsSub != null && _logs.isNotEmpty)
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
    // bool per = await Permissions.contactPermissionsGranted();
    // if (per) {
    // _logsSub = getLocalLogs().listen((event) {
    // }
    // }
    // per = await Permissions.contactPermissionsGranted();
    // _logsCont.add(null);
  }

  void pause() {
    if (_logsSub != null) {
      _logsSub.pause();
      print('PAUSED');
    }
  }

  void resume() async {
    if (await Permissions.contactPermissionsGranted()) {
      _logsSub.resume();
      print('RESUMED');
    }
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
      bool per = await Permissions.contactPermissionsGranted();
      while (true) {
        // if (!per) per = await Permissions.contactPermissionsGranted();
        await Future.delayed(Duration(milliseconds: 500));
        if (!per)
          yield [];
        else {
          yield await CallLog.get();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  StreamController<Iterable<CallLogEntry>> get controller => _logsCont;
  List<CallLogEntry> get contactList => _logs;
}
