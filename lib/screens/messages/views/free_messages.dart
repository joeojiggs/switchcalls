import 'dart:async';
import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:switchcalls/widgets/quiet_box.dart';
import 'package:switchcalls/models/chat.dart';

import '../providers/message_list_provider.dart';
import '../widgets/chat_tile.dart';

class FreeMessages extends StatefulWidget {
  final StreamController<List<Chat>> controller;
  final User user;

  FreeMessages({
    Key key,
    this.controller, this.user,
  }) : super(key: key);

  @override
  _FreeMessagesState createState() => _FreeMessagesState();
}

class _FreeMessagesState extends State<FreeMessages> {
  ChatMethods _messages = ChatMethods();
  AuthMethods _authMethods = AuthMethods();
  MessageListProvider _messageListProvider = new MessageListProvider();

  @override
  void initState() {
    _authMethods.getCurrentUser().then((FirebaseUser user) {
      _messageListProvider.onInit(user.uid);
    });
    super.initState();
  }

  @override
  void dispose() {
    _messageListProvider.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chat>>(
      stream: _messageListProvider.controller?.stream,
      builder: (context, snapshot) {
        List<Chat> users = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (users.isEmpty) {
          return QuietBox();
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            Chat user = snapshot.data[index];
            return ChatTile(
              chat: user,
              uid: user.uid,
              date: user.toDateString(),
              unreads: _messages.unReadMessages(widget.user.uid, user.uid),
            );
          },
        );
      },
    );
  }
}
