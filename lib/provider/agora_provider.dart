import 'dart:convert';
import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:switchcalls/configs/agora_configs.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/resources/call_methods.dart';
import 'package:switchcalls/utils/call_utilities.dart';

class AgoraProvider extends ChangeNotifier {
  RtcEngine _engine;
  CallMethods callMethods = CallMethods();
  List<int> _users = <int>[];
  List<String> _infoStrings = <String>[];
  bool isVideo;

  final Map<String, dynamic> params = {
    "che.video.inactive_enable_encoding_and_decoding": true,
    "che.video.lowBitRateStreamParameter": {
      "width": 120,
      "height": 160,
      "frameRate": 5,
      "bitRate": 45
    },
  };

  Future<void> initializeAgora(Call call) async {
    CallUtils.initRingTone();
    if (APP_ID.isEmpty) {
      _infoStrings.add(
        'APP_ID missing, please provide your APP_ID in settings.dart',
      );
      _infoStrings.add('Agora Engine is not starting');
      return;
    }

    await _initAgoraRtcEngine(call);
    // await _engine.enableWebSdkInteroperability(true);
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
    } catch (e) {
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
        CallUtils.toggleRingSound(false);
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
      connectionStateChanged:
          (ConnectionStateType type, ConnectionChangedReason reason) {
        if (type == ConnectionStateType.Connected) {
          // CallUtils.toggleRingSound(false);
        } else {
          CallUtils.toggleRingSound(true);
        }
      },
      firstRemoteVideoFrame: (int uid, int width, int height, int elapsed) {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
        print(_infoStrings.last);
        notifyListeners();
      },
      // firstRemoteAudioFrame: (int uid, int elapsed) {
      //   CallUtils.toggleRingSound(false);
      // },
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
    try {
      this.isVideo = isVideo;
      await _engine.enableLocalVideo(isVideo);
      await _engine.muteLocalVideoStream(isVideo);
      await _engine.muteAllRemoteVideoStreams(isVideo);
    } catch (e) {
      print('Toggle Video Error: $e');
    }
  }

  Future<bool> toggleMute(bool isMute) async {
    try {
      await _engine.muteLocalAudioStream(!isMute);
      return !isMute;
    } catch (e) {
      print('Toggle Mute Error: $e');
      return isMute;
    }
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
        (int uid) => list.add(RtcRemoteView.SurfaceView(
          uid: uid,
        )),
      );
      yield list;
    }
  }

  Future<void> onSwitchCamera() async {
    try {
      await _engine.switchCamera();
    } catch (e) {
      print('Switch Camera Error: $e');
    }
  }

  // TODO: fix the speaker issue, check docs for the correct function to use
  Future<bool> toggleSpeaker(bool isLoud) async {
    try {
      await _engine.setDefaultAudioRoutetoSpeakerphone(isLoud);
      // setEnableSpeakerphone(isLoud);
      return !isLoud;
      // await _engine.audio
      // .isSpeakerphoneEnabled();
    } catch (e) {
      print('Toggle Speaker Error: $e');
      return isLoud;
    }
  }

  void close() {
    try {
      //
      CallUtils.closeRingTone();
      // clear users
      _users.clear();
      _infoStrings.clear();

      // destroy sdk
      _engine.leaveChannel();
      _engine.destroy();
    } catch (e) {
      print('close error: $e');
    }
  }

  List<int> get users => _users;
  List<String> get infoStrings => _infoStrings;
}
