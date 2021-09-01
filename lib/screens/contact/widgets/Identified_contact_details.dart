import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/screens/messages/views/chat_screen.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/call_utilities.dart';

class IdentifiedContactDetails extends StatelessWidget {
  IdentifiedContactDetails({Key key, this.contact, this.userProvider})
      : super(key: key);

  UserProvider userProvider;
  User contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: CachedImage(
              contact.profilePhoto,
              isRound: false,
              radius: 45,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    contact.username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 5),
          ListTile(
            title: Text('${contact.phoneNumber}'),
            trailing: ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.white,
                  onPressed: () async {
                    User receiver = contact;
                    if (await Permissions
                        .cameraAndMicrophonePermissionsGranted())
                      return CallUtils.dialAudio(
                        from: userProvider.getUser,
                        to: receiver,
                        context: context,
                      );
                    return;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.video_call),
                  color: Colors.white,
                  onPressed: () async {
                    User receiver = contact;
                    if (await Permissions
                        .cameraAndMicrophonePermissionsGranted())
                      return CallUtils.dial(
                        from: userProvider.getUser,
                        to: receiver,
                        context: context,
                      );
                    return;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(receiver: contact),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
