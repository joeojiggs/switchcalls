import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:switchcalls/models/message.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/image_upload_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class StorageMethods {
  static final Firestore firestore = Firestore.instance;
  final ChatMethods chatMethods = ChatMethods();
  http.Client _httpClient = http.Client();
  StorageReference _storageReference;

  //user class
  User user = User();

  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
          _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadImage({
    @required File image,
    @required Message message,
    @required ImageUploadProvider imageUploadProvider,
  }) async {
    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);

    message.url = url;
    // print(message.photoUrl);

    // Hide loading
    imageUploadProvider.setToIdle();

    chatMethods.sendMessage(message: message);
  }

  void uploadFile({
    @required File file,
    @required Message message,
    @required ImageUploadProvider imageUploadProvider,
  }) async {
    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    String url = await uploadImageToStorage(file);
    message.url = url;

    // Hide loading
    imageUploadProvider.setToIdle();

    chatMethods.sendMessage(message: message);
  }

  Future<void> downloadFile(String url, String filename) async {
    var request = await _httpClient.get(Uri.parse(url));
    var bytes = request.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}
