import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/constants/strings.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/models/log.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/widgets/toasts.dart';
import 'package:switchcalls/resources/call_methods.dart';
import 'package:switchcalls/resources/local_db/repository/log_repository.dart';
import 'package:switchcalls/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();
  static final assetsAudioPlayer = AssetsAudioPlayer();

  static dial({User from, User to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      isVideo: true,
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
      isVideo: 0,
    );

    if (call.receiverId == call.callerId) {
      Toasts.error("Sorry, you can't call yourself");
      return;
    }

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call, isVideo: true),
        ),
      );
    }
  }

  static dialAudio({User from, User to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      isVideo: false,
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
      isVideo: 1,
    );

    if (call.receiverId == call.callerId) {
      Toasts.error("Sorry, you can't call yourself");
      return;
    }

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call, isVideo: false),
        ),
      );
    }
  }

  static Future<void> toggleRingSound(value) async {
    if (value) {
      await assetsAudioPlayer.open(
        Audio('assets/audio/Phone Internal Ringing-Calling - Sound Effect.mp3'),
        loopMode: LoopMode.single,
      );
      assetsAudioPlayer.play();
    } else {
      assetsAudioPlayer.stop();
    }
  }
}
