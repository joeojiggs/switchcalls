import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/models/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchcalls/constants/strings.dart';
import 'package:switchcalls/utils/utilities.dart';

class ContactsProvider extends ChangeNotifier {
  static ContactsProvider provider;
  StreamController<Iterable<MyContact>> _contactsCont;
  StreamSubscription<Iterable<MyContact>> _contactSub;
  List<MyContact> _contacts = [];
  SharedPreferences _prefs;

  static Future<ContactsProvider> getInstance() async {
    if (provider == null) {
      ContactsProvider placeholder = ContactsProvider();
      await placeholder.init();
      provider = placeholder;
    }
    return provider;
  }

  Future<void> init([bool topause = false]) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _contactsCont = StreamController<Iterable<MyContact>>.broadcast();
      if (await Permissions.contactPermissionsGranted()) {
        _contactSub = contacts().listen((event) {
          _contacts = event.toList();
          // print(contactList);
          _contactsCont.add(event);
          if (topause) pause();
        });
        print('CONTACTS STARTED');
      }
      _contactsCont.add(null);
    } catch (e) {
      print(e.toString());
    }
  }

  void pause() {
    if (_contactSub != null) {
      _contactSub.pause();
      // _contactSub.cancel();
      print('CONTACTS PAUSED');
    }
  }

  void resume() {
    if (_contactSub != null) {
      _contactSub.resume();
      print('CONTACTS RESUMED');
    } else {
      init();
    }
  }

  void close() {
    _contactsCont.close();
    _contactSub.cancel();
    print('CONTACTS CLOSED');
  }

  Stream<Iterable<MyContact>> contacts() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));

      // get contacts on users device
      List<MyContact> cts = (await ContactsService.getContacts())
          .map((e) => MyContact(
                name: e?.displayName ?? '',
                uid: '',
                profilePic: '',
                localPic: e.avatar,
                numbers: e.phones.map((e) => e.value).toList(),
              ))
          .toList();

      cts = await formatAllNumbers(cts);

      await _prefs.setStringList(
          LOCAL_CONTACTS, cts.map((e) => jsonEncode(e.toMap())).toList());
      print("STORED CONTACTS");
      yield cts;
    }
  }

  Future<List<MyContact>> formatAllNumbers(List<MyContact> cts) async {
    try {
      List<MyContact> cts2 = [];
      // init list of country codes
      await Utils.numLib.init();

      // format all number gotten from users device
      for (MyContact ct in cts) {
        List<String> nums = [];
        for (String nu in ct.numbers) {
          String n = await Utils.formatNum(nu, true);
          nums.add(n);
        }
        cts2.add(MyContact(
          name: ct.name,
          uid: '',
          profilePic: '',
          localPic: ct.localPic,
          numbers: ct.numbers,
          formatNums: nums,
        ));
        // print(ct.formatNums);
      }
      return cts2;
    } catch (e) {
      return contactList;
    }
  }

  StreamController<Iterable<MyContact>> get controller => _contactsCont;
  List<MyContact> get contactList {
    _contacts = _prefs != null
        ? (_prefs.getStringList(LOCAL_CONTACTS) ?? [])
            ?.map((e) => MyContact.fromMap(jsonDecode(e)))
            ?.toList()
        : _contacts;
    _contacts.sort((a, b) => (a?.name ?? '').compareTo(b?.name ?? ''));
    _contacts = Utils.cleanList(_contacts);
    return _contacts;
  }
}
