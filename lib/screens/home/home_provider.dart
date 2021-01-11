import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_contact/contact.dart';
import 'package:contacts_service/contacts_service.dart';

class HomeProvider extends ChangeNotifier {
  StreamController<Iterable<Contact>> _contactsCont =
      StreamController<Iterable<Contact>>.broadcast();
  StreamSubscription<Iterable<Contact>> _contactSub;

  void init() {
    _contactSub = contacts().listen((event) {
      _contactsCont.add(event);
    });
  }

  void dispose() {
    _contactsCont.close();
    _contactSub.cancel();
    print('CLOSED');
  }

  Stream<Iterable<Contact>> contacts() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield await ContactsService.getContacts();
    }
  }
}
