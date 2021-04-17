import 'package:flutter/material.dart';
import 'package:switchcalls/models/call.dart';
import 'package:switchcalls/provider/agora_provider.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class VoiceCall extends StatelessWidget {
  final AgoraProvider agoraProvider;
  final Call call;
  final bool muted, isLoud;
  final Function onToggleMute, onToggleSpeaker, onEndCall;

  const VoiceCall({
    Key key,
    @required this.call,
    @required this.muted,
    @required this.onToggleMute,
    @required this.onEndCall,
    @required this.agoraProvider,
    @required this.isLoud,
    @required this.onToggleSpeaker,
  })  : assert(agoraProvider != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    print(muted);
    return SafeArea(
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
                call.hasDialled
                    ? call.receiverName ?? ''
                    : call.callerName ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
              child: CachedImage(
                call.hasDialled ? call.receiverPic ?? '' : call.callerPic ?? '',
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
                        onTap: onToggleMute,
                        child: Container(
                          decoration: BoxDecoration(
                            color: muted ? Colors.black38 : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(25.0),
                          child: Icon(
                            muted ? Icons.mic_off : Icons.mic,
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
                        onTap: onEndCall,
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
                    child: InkWell(
                      onTap: onToggleSpeaker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLoud ? Colors.black26 : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(25.0),
                        child: Icon(
                          Icons.volume_up,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
