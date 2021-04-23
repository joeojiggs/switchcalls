import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:switchcalls/screens/messages/widgets/online_dot_indicator.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/widgets/custom_tile.dart';
import 'package:switchcalls/models/chat.dart';

import '../views/message_screen.dart';

// ignore: must_be_immutable
class ChatTile extends StatelessWidget {
  final String uid;

  final String date;
  final Stream<int> unreads;
  final String currentUserId;
  final Chat chat;

  ChatTile(
      {Key key,
      this.uid,
      this.date,
      this.unreads,
      this.currentUserId,
      this.chat})
      : super(key: key);

  Stream<DocumentSnapshot> userInfo() {
    return Firestore.instance.collection("users").document(uid).snapshots();
  }

  User details;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userInfo(),
      builder: (context, snapshot) {
        DocumentSnapshot data = snapshot.data;
        if (!snapshot.hasData) {
          return Container();
        }

        details = User.fromMap(snapshot?.data?.data);
        return CustomTile(
          mini: false,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(receiver: details)),
          ),
          leading: Container(
            constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
            child: Stack(
              children: <Widget>[
                CachedImage(
                  details?.profilePhoto,
                  radius: 80,
                  isRound: true,
                ),
                OnlineDotIndicator(
                  uid: chat?.uid ?? '',
                ),
              ],
            ),
          ),
          title: Text(
            snapshot.hasData ? data.data['name'] : '',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Arial",
              fontSize: 19,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chat.lastMessage ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  date ?? '',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          // trailing: StreamBuilder<int>(
          //   stream: unreads,
          //   builder: (context, snapshot) {
          //     int value = snapshot.data;
          //     if (value != null && value > 0) {
          //       return CircleAvatar(
          //         backgroundColor: Colors.black,
          //         radius: 12,
          //         child: Text('$value'),
          //       );
          //     } else {
          //       return Container();
          //     }
          //   },
          // ),
        );
      },
    );
  }
}
