import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/models/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchcalls/constants/strings.dart';
import 'package:switchcalls/utils/utilities.dart';

class ContactsScreenProvider extends ChangeNotifier {
  SharedPreferences prefs;
  List<MyContact> cts;
  Future<List<MyContact>> init() async {
    prefs = await SharedPreferences.getInstance();
    cts = (prefs.getStringList(LOCAL_CONTACTS) ?? [])
        .map((e) => MyContact.fromMap(jsonDecode(e)))
        .toList();
    cts.sort((a, b) => a.name.compareTo(b.name));
    return cts;
  }

  List<User> filterIdentifiedCL(
      List<User> identified, List<MyContact> contacts, String query) {
    List<String> contNumbers = contacts
        ?.map((e) => (e.formatNums.length) > 0 ? e.formatNums.first : '')
        ?.toList();

    // keep numbers that the user has in his contact list.
    identified.retainWhere((element) =>
        contNumbers.any((e) => Utils.compareNumbers(element.phoneNumber, e)));

    //return the contact the user searched for
    Iterable<User> res = identified
        .where((element) => element.username.toLowerCase().contains(query))
        .toList();
    return res;
  }

  List<MyContact> filterLocalContacts(String query, List<MyContact> contacts) {
    List<MyContact> _contacts = [];
    _contacts.addAll(contacts);
    if (query.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = query.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact?.name?.toLowerCase();
        bool nameMatches = contactName?.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact?.numbers?.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn);
          return phnFlattened?.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }

    return _contacts;
  }

  List<MyContact> getAllContacts(
      List<MyContact> contactList, Map<String, Color> contactsColorMap) {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<MyContact> _contacts = contactList;
    //(await ContactsService.getContacts()).toList();
    print('\n\n\n HERE \n\n');
    _contacts.forEach((contact) {
      // print(colorIndex);
      Color baseColor = colors[colorIndex];
      // print(baseColor);
      contactsColorMap[contact?.name] = baseColor;
      colorIndex++;
      if (colorIndex == colors?.length) {
        colorIndex = 0;
      }
    });
    _contacts = Utils.cleanList(_contacts);
    return _contacts;
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }
}
