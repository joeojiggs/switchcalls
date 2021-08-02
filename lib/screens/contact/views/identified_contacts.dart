import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/chats/chat_methods.dart';
import 'package:switchcalls/screens/contact/providers/contacts_screen_provider.dart';
import 'package:switchcalls/screens/messages/views/chat_screen.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/call_utilities.dart';
import 'package:switchcalls/models/contact.dart';

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

  // List<User> searchedContacts(List<User> filtered) {
  //   String query = searchController.text.toLowerCase();

  //   Iterable<User> res = filtered
  //       .where((element) => element.username.toLowerCase().contains(query));

  //   return res.toList();
  // }

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _contactsProvider = Provider.of<ContactsProvider>(context, listen: false);

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
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: isSearching == true
                          ? searched.length
                          : filtered.length,
                      itemBuilder: (context, index) {
                        User contact = isSearching == true
                            ? searched[index]
                            : filtered[index];

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
                                return _buildInfo(context, contact);
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

  Container _buildInfo(BuildContext context, User contact) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: CachedImage(
              contact.profilePhoto,
              isRound: false,
              radius: 45,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    contact.username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 5),
          ListTile(
            title: Text('${contact.phoneNumber}'),
            trailing: ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.white,
                  onPressed: () async {
                    User receiver = contact;
                    if (await Permissions
                        .cameraAndMicrophonePermissionsGranted())
                      return CallUtils.dialAudio(
                        from: userProvider.getUser,
                        to: receiver,
                        context: context,
                      );
                    return;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.video_call),
                  color: Colors.white,
                  onPressed: () async {
                    User receiver = contact;
                    if (await Permissions
                        .cameraAndMicrophonePermissionsGranted())
                      return CallUtils.dial(
                        from: userProvider.getUser,
                        to: receiver,
                        context: context,
                      );
                    return;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(receiver: contact),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
