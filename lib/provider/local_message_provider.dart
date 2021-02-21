import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/utils/permissions.dart';

class MessageProvider extends ChangeNotifier {
  final SmsQuery _query = new SmsQuery();
  bool isLoading = true;
  List<SmsThread> messages;

  Future<List<SmsThread>> getthreads() async {
    try {
      if (await Permissions.smsPermissionsGranted()) {
        List<SmsThread> data = await _query.getAllThreads;
        return data;
        // isLoading = false;
      }
      throw Exception();
    } on Exception catch (e) {
      print(e.toString());
      throw Exception();
    }
  }
}
