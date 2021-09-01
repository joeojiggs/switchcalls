import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:switchcalls/screens/contact/providers/contacts_screen_provider.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/models/contact.dart';

import '../widgets/Identified_contact_details.dart';

class IdentifiedContacts extends StatefulWidget {
  IdentifiedContacts({
    Key key,
    @required this.contacts,
  }) : super(key: key);

  final List<MyContact> contacts;

  @override
  _IdentifiedContactsState createState() => _IdentifiedContactsState();
}

class _IdentifiedContactsState extends State<IdentifiedContacts> {
  final TextEditingController searchController = TextEditingController();
  final ChatMethods _chatMethods = ChatMethods();
  final ContactsScreenProvider _provider = ContactsScreenProvider();
  List<User> searched;
  ContactsProvider _contactsProvider;
  UserProvider userProvider;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _contactsProvider = Provider.of<ContactsProvider>(context, listen: false);
    // _contactsProvider.init(true);

    // searchController.addListener(() {
    //   setState(() {});
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Container(
      child: StreamBuilder<List<User>>(
        stream: _chatMethods.fetchContacts(),
        builder: (BuildContext context, snapshot) {
          List<User> identified = snapshot.data;
          // print(snapshot.data.map((e) => e.phoneNumber).toList());
          // print(_contactsProvider.contactList);
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (identified != null || identified.isNotEmpty) {
            List<User> filtered = _provider.filterIdentifiedCL(identified,
                _contactsProvider.contactList, searchController.text);
            filtered.removeWhere((element) =>
                element.phoneNumber == userProvider.getUser.phoneNumber);
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Visibility(
                      visible: filtered.length > 0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            isSearching ? searched.length : filtered.length,
                        itemBuilder: (context, index) {
                          User contact =
                              isSearching ? searched[index] : filtered[index];

                          return ListTile(
                            title: Text(contact.username),
                            subtitle: Text(contact.phoneNumber),
                            leading: CachedImage(
                              contact.profilePhoto,
                              isRound: true,
                              radius: 45,
                            ),
                            onTap: () async {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: UniversalVariables.blackColor,
                                builder: (context) {
                                  return IdentifiedContactDetails(
                                    contact: contact,
                                    userProvider: userProvider,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      replacement: Center(
                        child: Text(
                          'You do not have any identified contacts.',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (identified.isEmpty) {
            return Center(
              child: Text(
                'You do not have any identified contacts.',
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
