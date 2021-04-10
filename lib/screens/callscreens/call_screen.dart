import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/provider/agora_provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/call_methods.dart';

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

  // List<int> _users = <int>[];
  // final _infoStrings = <String>[];
  bool muted = false;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    // initializeAgora();
  }

  void myAgoraInit() async {
    agoraProvider.isVideo = widget.isVideo;
    await agoraProvider.initializeAgora(widget.call);
    // _users = agoraProvider.users;
  }

  // Future<void> initializeAgora() async {
  //   if (APP_ID.isEmpty) {
  //     setState(() {
  //       _infoStrings.add(
  //         'APP_ID missing, please provide your APP_ID in settings.dart',
  //       );
  //       _infoStrings.add('Agora Engine is not starting');
  //     });
  //     return;
  //   }

  //   await _initAgoraRtcEngine();
  //   _addAgoraEventHandlers();
  //   await AgoraRtcEngine.enableWebSdkInteroperability(true);
  //   await AgoraRtcEngine.setParameters(
  //       '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
  //   await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);
  // }

  void addPostFrameCallback() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    agoraProvider = Provider.of<AgoraProvider>(context, listen: false);
    myAgoraInit();
    SchedulerBinding.instance.addPostFrameCallback((_) {
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

  // /// Helper function to get list of native views
  // List<Widget> _getRenderViews() {
  //   final List<AgoraRenderWidget> list = [
  //     AgoraRenderWidget(0, local: true, preview: true),
  //   ];
  //   _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
  //   return list;
  // }

  // void onToggleMute() {
  //   setState(() {
  //     muted = !muted;
  //   });
  //   AgoraRtcEngine.muteLocalAudioStream(muted);
  // }

  // void onSwitchCamera() {
  //   AgoraRtcEngine.switchCamera();
  // }

  @override
  void dispose() {
    // // clear users
    // _users.clear();
    // // destroy sdk
    // AgoraRtcEngine.leaveChannel();
    // AgoraRtcEngine.destroy();
    agoraProvider.close();
    callStreamSubscription.cancel();
    super.dispose();
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
              onToggleMute: () async {
                // muted = await agoraProvider.toggleMute(muted);
                // setState(() {});
                await agoraProvider.toggleVideo(!agoraProvider.isVideo);

                setState(() {});
              },
              onEndCall: () async {
                debugPrint('ENDING CALL');
                await callMethods.endCall(call: widget.call);
              },
            )
          : VoiceCall(
        muted: muted,
        call: widget.call,
        onToggleMute: () async {
          // await agoraProvider.toggleVideo(!agoraProvider.isVideo);
          muted = await agoraProvider.toggleMute(muted);
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

class VideoCall extends StatelessWidget {
  final Function onToggleMute, onEndCall, onSwitchCamera;
  final bool muted;
  final List<String> infoStrings;
  final AgoraProvider agoraProvider;
  final Call call;

  const VideoCall({
    Key key,
    this.onToggleMute,
    this.onEndCall,
    this.onSwitchCamera,
    this.muted,
    this.infoStrings,
    this.agoraProvider,
    this.call,
  })  : assert(agoraProvider != null),
        super(key: key);

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows(List<Widget> views) {
    // List<Widget> views = agoraProvider.getRenderViews();
    print(views);
    switch (views.length) {
      case 1:
        return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ),
        );
      case 2:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow([views[0]]),
              _expandedVideoRow([views[1]])
            ],
          ),
        );
      case 3:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 3))
            ],
          ),
        );
      case 4:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 4))
            ],
          ),
        );
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: onEndCall,
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: () async {
              await agoraProvider.onSwitchCamera();
            },
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: StreamBuilder<List<Widget>>(
            stream: agoraProvider.getRenderViews(),
            builder: (context, snapshot) {
              return Stack(
                children: <Widget>[
                  _viewRows(snapshot.data ?? []),
                  _panel(),
                  _toolbar(),
                ],
              );
            }),
      ),
    );
  }
}

// /// Create agora sdk instance and initialize
// Future<void> _initAgoraRtcEngine() async {
//   await AgoraRtcEngine.create(APP_ID);
//   await AgoraRtcEngine.enableVideo();
// }

// /// Add agora event handlers
// void _addAgoraEventHandlers() {
//   AgoraRtcEngine.onError = (dynamic code) {
//     setState(() {
//       final info = 'onError: $code';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onJoinChannelSuccess =
//       (String channel, int uid, int elapsed) {
//     setState(() {
//       final info = 'onJoinChannel: $channel, uid: $uid';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
//     setState(() {
//       final info = 'onUserJoined: $uid';
//       _infoStrings.add(info);
//       _users.add(uid);
//     });
//   };

//   AgoraRtcEngine.onUpdatedUserInfo = (AgoraUserInfo userInfo, int i) {
//     setState(() {
//       final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onRejoinChannelSuccess = (String string, int a, int b) {
//     setState(() {
//       final info = 'onRejoinChannelSuccess: $string';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onUserOffline = (int a, int b) {
//     callMethods.endCall(call: widget.call);
//     setState(() {
//       final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onRegisteredLocalUser = (String s, int i) {
//     setState(() {
//       final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onLeaveChannel = () {
//     setState(() {
//       _infoStrings.add('onLeaveChannel');
//       _users.clear();
//     });
//   };

//   AgoraRtcEngine.onConnectionLost = () {
//     setState(() {
//       final info = 'onConnectionLost';
//       _infoStrings.add(info);
//     });
//   };

//   AgoraRtcEngine.onUserOffline = (int uid, int reason) {
//     // if call was picked

//     setState(() {
//       final info = 'userOffline: $uid';
//       _infoStrings.add(info);
//       _users.remove(uid);
//     });
//   };

//   AgoraRtcEngine.onFirstRemoteVideoFrame = (
//     int uid,
//     int width,
//     int height,
//     int elapsed,
//   ) {
//     setState(() {
//       final info = 'firstRemoteVideo: $uid ${width}x $height';
//       _infoStrings.add(info);
//     });
//   };
// }
