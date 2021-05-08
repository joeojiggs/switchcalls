import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/utils/permissions.dart';

class MessageProvider extends ChangeNotifier {
  static MessageProvider provider;
  final SmsQuery _query = new SmsQuery();
  StreamController<List<SmsThread>> _smsCont;
  StreamSubscription<List<SmsThread>> _smsSub;
  bool isLoading = true;
  List<SmsThread> _messages = [];

  static Future<MessageProvider> getInstance() async {
    if (provider == null) {
      MessageProvider placeholder = MessageProvider();
      await placeholder.init();
      provider = placeholder;
    }
    return provider;
  }

  Future<List<SmsThread>> getthreads() async {
    try {
      if (await Permissions.smsPermissionsGranted()) {
        List<SmsThread> data = await _query.getAllThreads;
        _messages = data;
        return data;
        // isLoading = false;
      }
      throw Exception();
    } on Exception catch (e) {
      print(e.toString());
      throw Exception();
    }
  }

  Future<void> init() async {
    try {
      _smsCont = StreamController<List<SmsThread>>.broadcast();
      if (await Permissions.smsPermissionsGranted()) {
        _smsSub = loadMessages().listen((event) {
          _messages = event.toList();
          // print(contactList);
          _smsCont.add(event);
          pause();
        });
      }
      print('SMS STARTED');
    } catch (e) {
      print(e.toString());
    }
  }

  void pause() {
    if (_smsSub != null) {
      _smsSub.pause();
      // _contactSub.cancel();
      print('CONTACTS PAUSED');
    }
  }

  void resume() {
    if (_smsSub != null) {
      _smsSub.resume();
      print('CONTACTS RESUMED');
    } else {
      init();
    }
  }

  void close() {
    _smsCont.close();
    _smsSub.cancel();
    print('SMS CLOSED');
  }

  Stream<List<SmsThread>> loadMessages() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      yield await _query.getAllThreads;
    }
  }

  StreamController<List<SmsThread>> get controller => _smsCont;
  List<SmsThread> get messages => _messages;
}
