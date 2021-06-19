import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart' as INPH;

class ContactsScreenProvider extends ChangeNotifier {
  // Map<String, Color> contactsColorMap = {};
  // INPH.PhoneNumber _number = INPH.PhoneNumber;
  // _nub
  // _number.parseNumber();

  List<User> filterIdentifiedCL(
      List<User> identified, List<Contact> contacts, String query) {
    List<String> contNumbers = contacts
        ?.map((e) => (e?.phones?.length ?? 0) > 0
            ? e?.phones?.first?.value?.substring(1)
            : '').map((e) => e.replaceAll(' ', ''))
        ?.toList();
    // INPH.PhoneNumber.getParsableNumber(INPH.PhoneNumber())

    print(contNumbers);

    // identified = identified.map((e) => e.phoneNumber.substring(1)).toList();

    identified.retainWhere(
        (element) => contNumbers?.contains(element?.phoneNumber?.substring(4)));

    Iterable<User> res = identified
        .where((element) => element.username.toLowerCase().contains(query))
        .toList();
    return res;
  }

  List<Contact> filterLocalContacts(String query, List<Contact> contacts) {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (query.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = query.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact?.displayName?.toLowerCase();
        bool nameMatches = contactName?.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact?.phones?.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened?.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }

    return _contacts;
  }

  List<Contact> getAllContacts(
      List<Contact> contactList, Map<String, Color> contactsColorMap) {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<Contact> _contacts = contactList;
    //(await ContactsService.getContacts()).toList();
    print('\n\n\n HERE \n\n');
    _contacts.forEach((contact) {
      // print(colorIndex);
      Color baseColor = colors[colorIndex];
      // print(baseColor);
      contactsColorMap[contact?.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors?.length) {
        colorIndex = 0;
      }
    });
    return _contacts;
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }
}
