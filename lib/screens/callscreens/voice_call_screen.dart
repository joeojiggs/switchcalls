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
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class VoiceCallScreen extends StatefulWidget {
  final Call call;

  const VoiceCallScreen({Key key, this.call}) : super(key: key);

  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final CallMethods callMethods = CallMethods();
  UserProvider userProvider;
  StreamSubscription callStreamSubscription;
  AgoraProvider agoraProvider;

  bool muted = false;
  List<int> _users = <int>[];

  @override
  void initState() {
    //TODO: Test, add timer and contacts
    super.initState();
    addPostFrameCallback();
    // initializeAgora();
  }

  void myAgoraInit() async {
    await agoraProvider.initializeAgora(widget.call);
    _users = agoraProvider.users;
  }

  void addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      agoraProvider = Provider.of<AgoraProvider>(context, listen: false);

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
      myAgoraInit();
    });
  }

  // Future<void> initializeAgora() async {
  //   if (APP_ID.isEmpty) {
  //     // setState(() {
  //     // _infoStrings.add(
  //     //     'APP_ID missing, please provide your APP_ID in settings.dart',
  //     //   );
  //     // _infoStrings.add('Agora Engine is not starting');
  //     // });
  //     return;
  //   }

  //   await _initAgoraRtcEngine();
  //   // _addAgoraEventHandlers();
  //   await AgoraRtcEngine.enableWebSdkInteroperability(true);
  //   await AgoraRtcEngine.setParameters(
  //       '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
  //   await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);
  // }

  // Future<void> _initAgoraRtcEngine() async {
  //   await AgoraRtcEngine.create(APP_ID);
  //   await AgoraRtcEngine.disableVideo();
  //   print('\n\n HERE \n\n');
  // }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    // _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
        return Container();
    }
  }

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

  // Future<void> _onToggleMute() async {
  //   await AgoraRtcEngine.muteLocalAudioStream(!muted);
  //   setState(() {
  //     muted = !muted;
  //   });
  // }

  @override
  void dispose() {
    agoraProvider.close();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10 * 0.8,
                color: UniversalVariables.blueColor,
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  widget.call.receiverName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
              Expanded(
                child: CachedImage(
                  widget.call.receiverPic,
                  fit: BoxFit.fitWidth,
                  // isRound: true,
                  radius: 0,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10 * 1.3,
                color: UniversalVariables.blueColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            muted = await agoraProvider.onToggleMute(muted);
                            setState(() {});
                          },
                          child: Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Icon(
                              muted ? Icons.mic : Icons.mic_off,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        shape: CircleBorder(),
                        elevation: 20,
                        child: GestureDetector(
                          onTap: () async {
                            debugPrint('ENDING CALL');
                            callMethods.endCall(call: widget.call);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(25.0),
                              child: Icon(
                                Icons.call_end,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Icon(
                          Icons.volume_up,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// void _addAgoraEventHandlers() {
//     AgoraRtcEngine.onError = (dynamic code) {
//       print('onError: $code');
//     };

//     AgoraRtcEngine.onJoinChannelSuccess =
//         (String channel, int uid, int elapsed) {
//       print('onJoinChannel: $channel, uid: $uid');
//     };

//     AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
//       setState(() {
//         final info = 'onUserJoined: $uid';
//         // _infoStrings.add(info);
//         _users.add(uid);
//       });
//     };

//     AgoraRtcEngine.onUpdatedUserInfo = (AgoraUserInfo userInfo, int i) {
//       setState(() {
//         final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
//         // _infoStrings.add(info);
//       });
//     };

//     AgoraRtcEngine.onRejoinChannelSuccess = (String string, int a, int b) {
//       setState(() {
//         final info = 'onRejoinChannelSuccess: $string';
//         // _infoStrings.add(info);
//       });
//     };

//     AgoraRtcEngine.onUserOffline = (int a, int b) {
//       callMethods.endCall(call: widget.call);
//       setState(() {
//         final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
//         // _infoStrings.add(info);
//       });
//     };

//     AgoraRtcEngine.onRegisteredLocalUser = (String s, int i) {
//       setState(() {
//         final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
//         // _infoStrings.add(info);
//       });
//     };

//     AgoraRtcEngine.onLeaveChannel = () {
//       setState(() {
//         // _infoStrings.add('onLeaveChannel');
//         _users.clear();
//       });
//     };

//     AgoraRtcEngine.onConnectionLost = () {
//       setState(() {
//         final info = 'onConnectionLost';
//         // _infoStrings.add(info);
//       });
//     };

//     AgoraRtcEngine.onUserOffline = (int uid, int reason) {
//       // if call was picked

//       setState(() {
//         final info = 'userOffline: $uid';
//         // _infoStrings.add(info);
//         _users.remove(uid);
//       });
//     };

//     AgoraRtcEngine.onFirstRemoteVideoFrame =
//         (int uid, int width, int height, int elapsed) {
//       setState(() {
//         final info = 'firstRemoteVideo: $uid ${width}x $height';
//         // _infoStrings.add(info);
//       });
//     };
//   }
