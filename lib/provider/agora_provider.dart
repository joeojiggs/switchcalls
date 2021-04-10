import 'dart:convert';
import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/configs/agora_configs.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/resources/call_methods.dart';

class AgoraProvider extends ChangeNotifier {
  CallMethods callMethods = CallMethods();
  List<int> _users = <int>[];
  List<String> _infoStrings = <String>[];
  bool isVideo = true;
  // StreamController<bool> _isVideoCont = StreamController<bool>.broadcast();
  // StreamSubscription<bool> _isVideoSub;

  Map<String, dynamic> params = {
    "che.video.lowBitRateStreamParameter": {
      "width": 320,
      "height": 180,
      "frameRate": 15,
      "bitRate": 140
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

    await _initAgoraRtcEngine();
    // _isVideoSub = _isVideoStream().listen((event) {
    //   _isVideoCont.add(event);
    // });
    _addAgoraEventHandlers(call);
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    // print(jsonEncode(params));
    await AgoraRtcEngine.setParameters(jsonEncode(params));
    await AgoraRtcEngine.joinChannel(null, call.channelId, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    try {
      await AgoraRtcEngine.create(APP_ID);
      await AgoraRtcEngine.enableVideo();

      await AgoraRtcEngine.setDefaultMuteAllRemoteVideoStreams(this.isVideo);
      await toggleVideo(this.isVideo);
      print('\n\n AgoraRtcEngine Initialized... \n\n');
    } on Exception catch (e) {
      print('_initAgoraRtcEngine Errorr: $e');
    }
  }

  void _addAgoraEventHandlers(Call call) {
    AgoraRtcEngine.onError = (dynamic code) {
      final info = 'onError: $code';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      final info = 'onJoinChannel: $channel, uid: $uid';
      print('\n\n\nCall Connected...\n\n\n');
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      final info = 'onUserJoined: $uid';
      _infoStrings.add(info);
      _users.add(uid);
      print('\n\n\n User Joined... \n\n\n');
    };

    AgoraRtcEngine.onUpdatedUserInfo = (AgoraUserInfo userInfo, int i) {
      final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onRejoinChannelSuccess = (String string, int a, int b) {
      final info = 'onRejoinChannelSuccess: $string';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onUserOffline = (int a, int b) {
      callMethods.endCall(call: call);
      final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onRegisteredLocalUser = (String s, int i) {
      final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onLeaveChannel = () {
      _infoStrings.add('onLeaveChannel');
      _users.clear();
    };

    AgoraRtcEngine.onConnectionLost = () {
      final info = 'onConnectionLost';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // if call was picked

      final info = 'userOffline: $uid';
      _infoStrings.add(info);
      _users.remove(uid);
      print(_infoStrings.last);
      notifyListeners();
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame =
        (int uid, int width, int height, int elapsed) {
      final info = 'firstRemoteVideo: $uid ${width}x $height';
      _infoStrings.add(info);
      print(_infoStrings.last);
      notifyListeners();
    };
  }

  Future<void> toggleVideo(bool isVideo) async {
    this.isVideo = isVideo;
    await AgoraRtcEngine.enableLocalVideo(isVideo);
    await AgoraRtcEngine.muteLocalVideoStream(isVideo);
    await AgoraRtcEngine.muteAllRemoteVideoStreams(isVideo);
  }

  Future<bool> toggleMute(bool isMute) async {
    await AgoraRtcEngine.muteLocalAudioStream(!isMute);
    return !isMute;
  }

  /// Helper function to get list of native views
  Stream<List<Widget>> getRenderViews() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      List<AgoraRenderWidget> list = [
        AgoraRenderWidget(0, local: true, preview: true),
      ];
      print('\n\n\n\n $_users \n\n\n\n');
      _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
      yield list;
    }
  }

  Future<void> onSwitchCamera() async {
    await AgoraRtcEngine.switchCamera();
  }

  // Stream<bool> _isVideoStream() async* {
  //   while (true) {
  //     await Future.delayed(Duration(seconds: 1));
  //     yield isVideo;
  //   }
  // }

  void close() {
    try {
      // clear users
      _users.clear();
      _infoStrings.clear();
      // destroy sdk
      AgoraRtcEngine.leaveChannel();
      AgoraRtcEngine.destroy();
    } on Exception catch (e) {
      print('close error: $e');
    }
  }

  List<int> get users => _users;
  List<String> get infoStrings => _infoStrings;
}
