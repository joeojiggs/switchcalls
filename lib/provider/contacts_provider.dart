import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:switchcalls/utils/permissions.dart';

class ContactsProvider extends ChangeNotifier {
  static ContactsProvider provider;
  StreamController<Iterable<Contact>> _contactsCont;
  StreamSubscription<Iterable<Contact>> _contactSub;
  List<Contact> _contacts = [];

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
      _contactsCont = StreamController<Iterable<Contact>>.broadcast();
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

  Stream<Iterable<Contact>> contacts() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      yield await ContactsService.getContacts();
    }
  }

  StreamController<Iterable<Contact>> get controller => _contactsCont;
  List<Contact> get contactList {
    _contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    return _contacts;
  }
}
