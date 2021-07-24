import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:switchcalls/models/chat.dart';

class MessageListProvider extends ChangeNotifier {

  MessageListProvider(){
    
  }
  // final String userId;
  ChatMethods _messages = ChatMethods();
  StreamSubscription<QuerySnapshot> _chatsub;
  StreamController<List<Chat>> _chatCont =
      StreamController<List<Chat>>.broadcast();


  void onInit(String userId) {
    _chatsub = _messages
        .chatDB(userId)
        .listen((event) => _messages.messageList(event, _chatCont));
  }

  void onClose() {
    _chatCont.close();
    _chatsub.cancel();
  }

  // Stream<int> getUnreads(String userId) {
  //   return _messages.unReadMessages(userId);
  // }

  StreamController<List<Chat>> get controller => _chatCont;
  StreamSubscription<QuerySnapshot> get sub => _chatsub;
}
