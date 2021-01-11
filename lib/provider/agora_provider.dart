import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/configs/agora_configs.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/resources/call_methods.dart';

class AgoraProvider extends ChangeNotifier {
  CallMethods callMethods = CallMethods();
  List<int> _users = <int>[];
  List<String> _infoStrings = <String>[];

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
    _addAgoraEventHandlers(call);
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    print(params.toString());
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, call.channelId, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.disableVideo();
    print('\n\n AgoraRtcEngine Initialized... \n\n');
  }

  void _addAgoraEventHandlers(Call call) {
    AgoraRtcEngine.onError = (dynamic code) {
      final info = 'onError: $code';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      final info = 'onJoinChannel: $channel, uid: $uid';
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      final info = 'onUserJoined: $uid';
      _infoStrings.add(info);
      _users.add(uid);
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
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      final info = 'firstRemoteVideo: $uid ${width}x $height';
      _infoStrings.add(info);
    };
  }

  /// Helper function to get list of native views

}
