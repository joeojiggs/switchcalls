import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class MyContact {
  final String name;
  final String uid;
  List<String> numbers;
  final String profilePic;
  final Uint8List localPic;
  final Timestamp addedOn;

  MyContact({
    this.name = '',
    this.uid = '',
    this.numbers,
    this.profilePic = '',
    this.localPic,
    this.addedOn,
  })  : assert(name != null),
        assert(uid != null),
        assert(profilePic != null);

  String get initials =>
      this.name?.split(' ')?.map((e) => e[0])?.join()?.toUpperCase();

  List<String> get trimNums =>
      this.numbers?.map((e) => e.replaceAll(' ', ''))?.toList() ?? [];

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'profilePic': this.profilePic,
        'contact_id': this.uid,
        'numbers': this.numbers,
        'added_on': this.addedOn,
      };

  factory MyContact.fromMap(Map<String, dynamic> mapData) {
    return MyContact(
      uid: mapData['contact_id'],
      addedOn: mapData["added_on"],
      name: mapData['name'],
      profilePic: mapData['profilePic'],
      numbers: parseNumbers(mapData['numbers']),
    );
  }

  static List<String> parseNumbers(dynamic data) {
    List<String> list = new List();
    if (data is String) {
      list.add(data);
      return list;
    } else if (data is List) {
      return data;
    } else {
      list.add(data);
      return list;
    }
  }
}
