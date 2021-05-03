import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/screens/contact/providers/contacts_screen_provider.dart';
import 'package:switchcalls/utils/universal_variables.dart';

import './contact_details.dart';

class LocalContacts extends StatelessWidget {
  LocalContacts({
    Key key,
    @required ContactsProvider contactsProvider,
    @required this.contacts,
    @required this.searchController,
    @required this.isSearching,
    @required this.contactsFiltered,
    @required this.contactsColorMap,
  })  : _contactsProvider = contactsProvider,
        super(key: key);

  final ContactsProvider _contactsProvider;
  final TextEditingController searchController;
  final bool isSearching;
  final List<Contact> contactsFiltered;
  List<Contact> contacts;
  final Map<String, Color> contactsColorMap;
  final ContactsScreenProvider _provider = ContactsScreenProvider();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<Iterable<Contact>>(
        stream: _contactsProvider.controller.stream,
        builder: (BuildContext context, snapshot) {
          // print(snapshot.hasData);
          // print(_contactsProvider.contactList);
          if (contacts != _contactsProvider.contactList) {
            print('Contacts is refreshing');
            contacts = _provider.getAllContacts(
                _contactsProvider.contactList, contactsColorMap);
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              contacts.isEmpty)
            return Center(child: CircularProgressIndicator());
          if (contacts.isNotEmpty) {
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
                        Contact contact = isSearching == true
                            ? contactsFiltered[index]
                            : contacts[index];

                        var baseColor =
                            contactsColorMap[contact.displayName] as dynamic;
                        // print(contactsColorMap);

                        Color color1 = baseColor[800];
                        Color color2 = baseColor[400];
                        return ListTile(
                          title: Text(contact.displayName),
                          subtitle: Text(contact.phones.length > 0
                              ? contact.phones.elementAt(0).value
                              : ''),
                          leading: (contact.avatar != null &&
                                  contact.avatar.length > 0)
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(contact.avatar),
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
                                    child: Text(contact.initials(),
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                          onTap: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: UniversalVariables.blackColor,
                              builder: (context) {
                                return ContactDetails(
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
