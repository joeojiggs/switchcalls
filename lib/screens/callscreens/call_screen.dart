import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/provider/agora_provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/call_methods.dart';

import 'video_call_screen.dart';
import 'voice_call_screen.dart';

class CallScreen extends StatefulWidget {
  final bool isVideo;
  final Call call;

  CallScreen({
    @required this.call,
    this.isVideo,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();
  UserProvider userProvider;
  AgoraProvider agoraProvider;
  StreamSubscription callStreamSubscription;

  bool muted = false;
  bool isLoud = false;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
  }

  void myAgoraInit() async {
    await agoraProvider.initializeAgora(widget.call);
  }

  void addPostFrameCallback() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    agoraProvider = Provider.of<AgoraProvider>(context, listen: false);
    agoraProvider.isVideo = widget.isVideo;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      myAgoraInit();
      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    try {
      agoraProvider.close();
      callStreamSubscription.cancel();
      super.dispose();
    } catch (e) {
      print('dispose error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: agoraProvider.isVideo ?? widget.isVideo
          ? VideoCall(
              infoStrings: agoraProvider.infoStrings,
              muted: muted,
              agoraProvider: agoraProvider,
              call: widget.call,
              onToggleMute: () async {
                muted = await agoraProvider.toggleMute(muted);
                // await agoraProvider.toggleVideo(!agoraProvider.isVideo);
                setState(() {});
              },
              onEndCall: () async {
                debugPrint('ENDING CALL');
                await callMethods.endCall(call: widget.call);
              },
            )
          : VoiceCall(
              muted: muted,
              isLoud: isLoud,
              call: widget.call,
              agoraProvider: agoraProvider,
              onToggleMute: () async {
                // await agoraProvider.toggleVideo(!agoraProvider.isVideo);
                muted = await agoraProvider.toggleMute(muted);
                setState(() {});
              },
              onToggleSpeaker: () async {
                isLoud = await agoraProvider.toggleSpeaker(isLoud);
                setState(() {});
              },
              onEndCall: () async {
                debugPrint('ENDING CALL');
                await callMethods.endCall(call: widget.call);
              },
            ),
    );
  }
}