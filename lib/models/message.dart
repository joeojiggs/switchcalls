import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:switchcalls/models/contact.dart';

class Message {
  String senderId;
  String receiverId;
  Timestamp timestamp;
  String type;
  bool isRead;

  String message;
  String url;
  MyFile file;
  MyContact contact;
  MyLocation location;

  Message({
    @required this.senderId,
    @required this.receiverId,
    @required this.type,
    @required this.timestamp,
    this.isRead,
    this.url,
    this.message,
    this.file,
    this.contact,
    this.location,
  });

  //Will be only called when you wish to send an image
  // named constructor
  Message.imageMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.url,
    this.isRead,
  });

  Map<String, dynamic> toMap() => {
        'senderId': this.senderId,
        'receiverId': this.receiverId,
        'timestamp': this.timestamp,
        'type': this.type,
        'isRead': this.isRead,
        'message': this.message,
        'url': this.url,
        'file': this.file?.toMap() ?? {},
        'contact': this.contact?.toMap() ?? {},
        'location': this.location?.toMap() ?? {},
      };

  // Map<String, dynamic> toImageMap() {
  //   var map = Map<String, dynamic>();
  //   map['message'] = this.message;
  //   map['senderId'] = this.senderId;
  //   map['receiverId'] = this.receiverId;
  //   map['type'] = this.type;
  //   map['timestamp'] = this.timestamp;
  //   map['photoUrl'] = this.photoUrl;
  //   return map;
  // }

  // named constructor
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      type: map['type'],
      timestamp: map['timestamp'],
      isRead: map['isRead'],
      message: map['message'],
      url: map['url'] != null ? map['url'] : null,
      file:
          (map['file'] as Map).isNotEmpty ? MyFile.fromMap(map['file']) : null,
      contact: (map['contact'] as Map).isNotEmpty
          ? MyContact.fromMap(map['contact'])
          : null,
      location: (map['location'] as Map).isNotEmpty
          ? MyLocation.fromMap(map['location'])
          : null,
    );
  }
}

class FileMessage {
  bool isDownloading;
  // bool hasDownloaded;
  Message message;

  FileMessage({this.message, this.isDownloading = false});

  bool get hasDownloaded => File(this.message.file.path).existsSync() ?? false;
}

class MyFile {
  final String path;
  final String name;

  MyFile({this.path, this.name});

  String get type => File(this.path).statSync().type.toString();

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'path': this.path,
      };

  factory MyFile.fromMap(Map map) {
    return MyFile(name: map['name'], path: map['path']);
  }
}

class MyLocation {
  final double long;
  final double lat;

  MyLocation({this.long, this.lat});

  Map<String, dynamic> toMap() {
    return {
      'long': this.long,
      'lat': this.lat,
    };
  }

  factory MyLocation.fromMap(Map map) {
    return MyLocation(
      long: map['long'],
      lat: map['lat'],
    );
  }
}
