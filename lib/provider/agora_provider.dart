import 'dart:convert';
import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:switchcalls/configs/agora_configs.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/resources/call_methods.dart';

class AgoraProvider extends ChangeNotifier {
  RtcEngine _engine;
  CallMethods callMethods = CallMethods();
  List<int> _users = <int>[];
  List<String> _infoStrings = <String>[];
  bool isVideo = true;
  // StreamController<bool> _isVideoCont = StreamController<bool>.broadcast();
  // StreamSubscription<bool> _isVideoSub;

  Map<String, dynamic> params = {
    "che.video.inactive_enable_encoding_and_decoding": true,
    "che.video.lowBitRateStreamParameter": {
      "width": 120,
      "height": 160,
      "frameRate": 5,
      "bitRate": 45
    },
  }; 

  Future<void> initializeAgora(Call call) async {
    if (APP_ID.isEmpty) {
      _infoStrings.add(
        'APP_ID missing, please provide your APP_ID in settings.dart',
      );
      _infoStrings.add('Agora Engine is not starting');
      return;
    }

    await _initAgoraRtcEngine(call);
    // _addAgoraEventHandlers(call);
    // await _engine.enableWebSdkInteroperability(true);
    // print(jsonEncode(params));
    await _engine.setParameters(jsonEncode(params));
    await _engine.joinChannel(null, call.channelId, null, 0);
  }

  Future<void> _initAgoraRtcEngine(Call call) async {
    try {
      _engine = await RtcEngine.createWithConfig(RtcEngineConfig(APP_ID));
      await _engine.enableVideo();
      _engine.setEventHandler(_addAgoraEventHandlers(call));

      // await _engine.muteAllRemoteVideoStreams(!this.isVideo);
      // await toggleVideo(this.isVideo);
      print('\n\n AgoraRtcEngine Initialized... \n\n');
    } on Exception catch (e) {
      print('_initAgoraRtcEngine Errorr: $e');
    }
  }

  RtcEngineEventHandler _addAgoraEventHandlers(Call call) {
    return RtcEngineEventHandler(
      error: (ErrorCode code) {
        final info = 'onError: $code';
        _infoStrings.add(info);
      },
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        final info = 'onJoinChannel: $channel, uid: $uid';
        print('\n\n\nCall Connected...\n\n\n');
        _infoStrings.add(info);
      },
      userJoined: (int uid, int elapsed) {
        final info = 'onUserJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
        print('\n\n\n User Joined... \n\n\n');
      },
      userInfoUpdated: (int i, UserInfo userInfo) {
        final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
        _infoStrings.add(info);
      },
      rejoinChannelSuccess: (String string, int a, int b) {
        final info = 'onRejoinChannelSuccess: $string';
        _infoStrings.add(info);
      },
      localUserRegistered: (int i, String s) {
        final info = 'onRegisteredLocalUser: string: $s, i: ${i.toString()}';
        _infoStrings.add(info);
      },
      leaveChannel: (RtcStats stats) {
        _infoStrings.add('onLeaveChannel: $stats');
        _users.clear();
      },
      connectionLost: () {
        final info = 'onConnectionLost';
        _infoStrings.add(info);
      },
      firstRemoteVideoFrame: (int uid, int width, int height, int elapsed) {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
        print(_infoStrings.last);
        notifyListeners();
      },
      userOffline: (int a, UserOfflineReason b) {
        callMethods.endCall(call: call);
        final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
        _infoStrings.add(info);
      },
    );

    // _engine.onUserOffline = (int uid, int reason) {
    //   // if call was picked

    //   final info = 'userOffline: $uid';
    //   _infoStrings.add(info);
    //   _users.remove(uid);
    //   print(_infoStrings.last);
    //   notifyListeners();
    // };
  }

  Future<void> toggleVideo(bool isVideo) async {
    this.isVideo = isVideo;
    await _engine.enableLocalVideo(isVideo);
    await _engine.muteLocalVideoStream(isVideo);
    await _engine.muteAllRemoteVideoStreams(isVideo);
  }

  Future<bool> toggleMute(bool isMute) async {
    await _engine.muteLocalAudioStream(!isMute);
    return !isMute;
  }

  /// Helper function to get list of native views
  Stream<List<Widget>> getRenderViews() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      List<Widget> list = [
        RtcLocalView.SurfaceView(),
      ];
      print('\n\n\n\n $_users \n\n\n\n');
      _users.forEach(
        (int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid,)),
      );
      yield list;
    }
  }

  Future<void> onSwitchCamera() async {
    await _engine.switchCamera();
  }

  void close() {
    try {
      // clear users
      _users.clear();
      _infoStrings.clear();
      // destroy sdk
      _engine.leaveChannel();
      _engine.destroy();
    } on Exception catch (e) {
      print('close error: $e');
    }
  }

  List<int> get users => _users;
  List<String> get infoStrings => _infoStrings;
}
