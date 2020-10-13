import 'dart:math';

import 'package:flutter/material.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/call_methods.dart';
import 'package:switchcalls/screens/callscreens/call_screen.dart';
import 'package:switchcalls/utils/utilities.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({User from, User to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}
