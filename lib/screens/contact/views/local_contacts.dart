import 'package:flutter/material.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/screens/contact/providers/contacts_screen_provider.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/models/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/local_contact_details.dart';

class LocalContacts extends StatelessWidget {
  LocalContacts({
    Key key,
    @required ContactsProvider contactsProvider,
    @required this.contacts,
    @required this.searchController,
    @required this.isSearching,
    @required this.contactsFiltered,
    @required this.contactsColorMap,
    @required this.prefs,
    this.provider,
  })  : _contactsProvider = contactsProvider,
        super(key: key);

  final ContactsProvider _contactsProvider;
  final TextEditingController searchController;
  final bool isSearching;
  final SharedPreferences prefs;
  List<MyContact> contactsFiltered;
  List<MyContact> contacts;
  final Map<String, Color> contactsColorMap;
  final ContactsScreenProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<Iterable<MyContact>>(
        stream: _contactsProvider.controller.stream,
        builder: (BuildContext context, snapshot) {
          // print(snapshot.hasData);
          // print(_contactsProvider.contactList.sublist(0, 5));
          if (contacts != provider.cts ?? _contactsProvider.contactList) {
            print('Contacts is refreshing');
            contacts = provider.getAllContacts(
                provider.cts ?? _contactsProvider.contactList,
                contactsColorMap);
          }
          // print(contacts.sublist(0, 5));
          if (snapshot.connectionState == ConnectionState.waiting &&
              contacts.isEmpty)
            return Center(child: CircularProgressIndicator());
          if (contacts.isNotEmpty) {
            if (isSearching)
              contactsFiltered =
                  provider.filterLocalContacts(searchController.text, contacts);
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          labelText: 'Search',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          prefixIcon: Icon(Icons.search,
                              color: Theme.of(context).primaryColor)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: isSearching == true
                          ? contactsFiltered.length
                          : contacts.length,
                      itemBuilder: (context, index) {
                        MyContact contact = isSearching == true
                            ? contactsFiltered[index]
                            : contacts[index];

                        var baseColor =
                            contactsColorMap[contact.name] as dynamic;
                        // print(contactsColorMap);

                        Color color1 = baseColor[800];
                        Color color2 = baseColor[400];
                        return ListTile(
                          title: Text('${contact.name ?? ''}'),
                          subtitle: Text(contact.numbers.length > 0
                              ? '${contact.numbers.elementAt(0)}'
                              : ''),
                          leading: (contact.localPic != null &&
                                  contact.localPic.length > 0)
                              ? CircleAvatar(
                                  backgroundImage:
                                      MemoryImage(contact.localPic),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          colors: [
                                            color1,
                                            color2,
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight)),
                                  child: CircleAvatar(
                                    child: Text(
                                      '${contact?.initials}',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                          onTap: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: UniversalVariables.blackColor,
                              builder: (context) {
                                return LocalContactDetails(
                                  color1: color1,
                                  color2: color2,
                                  contact: contact,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          if (contacts.isEmpty) {
            return Center(
              child: Text(
                'You do not have any contacts.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            );
          }
          return Center(
            child: Text(
              'No contacts were found. \n\n' +
                      (snapshot?.connectionState?.toString()) ??
                  '' + (snapshot?.error?.toString()) ??
                  '' + snapshot?.data?.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
