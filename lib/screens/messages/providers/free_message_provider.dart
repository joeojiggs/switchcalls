import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:switchcalls/models/message.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/image_upload_provider.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:switchcalls/resources/storage_methods.dart';
import 'package:switchcalls/utils/call_utilities.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/utilities.dart';

class FreeMessageProvider extends ChangeNotifier {
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _messages = ChatMethods();
  TextEditingController textFieldController = TextEditingController();
  ImageUploadProvider imageUploadProvider = ImageUploadProvider();

  final User receiver;
  User _sender;

  String currentUserId;

  bool isWriting = false;

  FreeMessageProvider({this.receiver}) : assert(receiver != null);

  set sender(User value) {
    _sender = value;
    currentUserId = value.uid;
    notifyListeners();
  }

  User get sender => _sender;

  void sendMessage(User sender, User receiver) {
    var text = textFieldController.text;

    Message _message = Message(
      receiverId: receiver.uid,
      senderId: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    isWriting = false;

    textFieldController.text = "";

    _messages.sendMessage(message: _message);
  }

  Future<void> makeCall(BuildContext context, bool isVideo, User sender) async {
    if (await Permissions.cameraAndMicrophonePermissionsGranted()) {
      if (isVideo) {
        return CallUtils.dial(
          from: sender,
          to: receiver,
          context: context,
        );
      } else {
        return CallUtils.dialAudio(
          from: sender,
          to: receiver,
          context: context,
        );
      }
    }
    return;
  }

  void pickImage(
      {@required ImageSource source, User sender, User receiver}) async {
    File selectedImage = await Utils.pickImage(source: source);

    Message _message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiver.uid,
        senderId: sender.uid,
        timestamp: Timestamp.now(),
        type: 'image');

    if (selectedImage != null)
      _storageMethods.uploadImage(
          image: selectedImage,
          message: _message,
          imageUploadProvider: imageUploadProvider);
  }

  void setWritingTo(bool val) {
    isWriting = val;
    notifyListeners();
  }

  Stream<List<Message>> messageStream(String userId) =>
      _messages.chatList(userId, receiver.uid);
}
