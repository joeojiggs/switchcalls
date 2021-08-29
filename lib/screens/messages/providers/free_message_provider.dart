import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:switchcalls/models/contact.dart';
import 'package:switchcalls/models/message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/image_upload_provider.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:switchcalls/resources/storage_methods.dart';
import 'package:switchcalls/screens/messages/widgets/select_contact.dart';
import 'package:switchcalls/utils/call_utilities.dart';
import 'package:switchcalls/utils/location_utils.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/utils/utilities.dart';
import 'package:switchcalls/enum/file_type.dart' as MyFiles;

class FreeMessageProvider extends ChangeNotifier {
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _messages = ChatMethods();
  TextEditingController textFieldController = TextEditingController();
  ImageUploadProvider imageUploadProvider = ImageUploadProvider();
  String chatDir = '';

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

    Message _message = Message(
      message: "IMAGE",
      receiverId: receiver.uid,
      senderId: sender.uid,
      timestamp: Timestamp.now(),
      type: MyFiles.FileUtils.fileTypeToString(MyFiles.FileType.image),
    );

    if (selectedImage != null)
      _storageMethods.uploadImage(
        image: selectedImage,
        message: _message,
        imageUploadProvider: imageUploadProvider,
      );
  }

  void pickFile(User sender, User receiver) async {
    FilePickerResult source = await FilePicker.platform.pickFiles();
    if (source != null && source.files.isNotEmpty) {
      Message _message = Message(
        message: "FILE",
        receiverId: receiver.uid,
        senderId: sender.uid,
        timestamp: Timestamp.now(),
        file: MyFile(
          name: source.files.first?.name,
          path: source.files.first?.path,
        ),
        type: MyFiles.FileUtils.fileTypeToString(MyFiles.FileType.file),
      );

      File file = File(source.files.single.path);
      _storageMethods.uploadFile(
        file: file,
        message: _message,
        imageUploadProvider: imageUploadProvider,
      );
    }
  }

  void setWritingTo(bool val) {
    bool isSame = isWriting;
    isWriting = val;
    if (isSame != isWriting) notifyListeners();
  }

  Stream<List<Message>> messageStream(String userId) =>
      _messages.chatList(userId, receiver.uid);

  Future<void> pickContact(BuildContext ctx, User sender, User receiver) async {
    MyContact _contact = await showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      backgroundColor: UniversalVariables.blackColor,
      builder: (context) => SelectContact(shouldReturn: true),
    );
    if (_contact != null) {
      print(_contact.toMap());
      Message _message = Message(
        receiverId: receiver.uid,
        senderId: sender.uid,
        timestamp: Timestamp.now(),
        type: MyFiles.FileUtils.fileTypeToString(MyFiles.FileType.contacts),
        contact: _contact,
      );

      _messages.sendMessage(message: _message);
    }
  }

  Future<void> getLocation(User sender, User receiver) async {
    MyLocation loc = await LocationUtils.getCurrentLocation();
    if (loc == null) {
      return;
    }
    Message _message = Message(
      receiverId: receiver.uid,
      senderId: sender.uid,
      timestamp: Timestamp.now(),
      type: MyFiles.FileUtils.fileTypeToString(MyFiles.FileType.location),
      location: loc,
    );

    _messages.sendMessage(message: _message);
  }

  bool doesFileExist(Message message) {
    // print("CHA DIR IS $chatDir");
    String dir = chatDir + '/' + message.senderId + '/' + message.file.name;
    print("CHA DIR IS $dir");
    bool res = File(dir).existsSync() ? true : false;
    print(res.toString().toUpperCase());
    return res;
  }

  void updateFile(Message message) {
    _messages.updateMessage(message);
  }

  Future<void> getDir() async {
    chatDir = await Utils.getDir();
  }
}
