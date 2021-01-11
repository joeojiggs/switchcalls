import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:switchcalls/utils/permissions.dart';

class ContactsProvider extends ChangeNotifier {
  static ContactsProvider provider;
  StreamController<Iterable<Contact>> _contactsCont =
      StreamController<Iterable<Contact>>.broadcast();
  StreamSubscription<Iterable<Contact>> _contactSub;
  Iterable<Contact> _contacts;

  static Future<ContactsProvider> getInstance() async {
    if (provider == null) {
      ContactsProvider placeholder = ContactsProvider();
      await placeholder.init();
      provider = placeholder;
    }
    return provider;
  }

  Future<void> init() async {
    await Permissions.contactPermissionsGranted();

    _contactSub = contacts().listen((event) {
      _contacts = event;
      print(contactList);
      _contactsCont.add(event);
    });
    print('STARTED');
  }

  void pause() {
    _contactSub.pause();
    // _contactSub.cancel();
    print('PAUSED');
  }

  void resume() {
    _contactSub.resume();
    // contacts().listen((event) {
    //   _contactsCont.add(event);
    // });
    print('RESUMED');
  }

  void close() {
    _contactsCont.close();
    _contactSub.cancel();
    print('CLOSED');
  }

  Stream<Iterable<Contact>> contacts() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      yield await ContactsService.getContacts();
    }
  }

  StreamController<Iterable<Contact>> get controller => _contactsCont;
  Iterable<Contact> get contactList => _contacts;
}
