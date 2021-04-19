import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:sms/contact.dart' as Sms;
import 'package:sms/sms.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/messages/views/message_screen.dart';
import 'package:switchcalls/screens/messages/views/text_message_screen.dart';
import 'package:switchcalls/utils/call_utilities.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class ContactListScreen extends StatefulWidget {
  ContactListScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();
  ContactsProvider _contactsProvider;

  @override
  void initState() {
    _contactsProvider = Provider.of<ContactsProvider>(context, listen: false);
    _contactsProvider.resume();

    super.initState();
    getPermissions();
  }

  @override
  void dispose() {
    _contactsProvider.pause();
    super.dispose();
  }

  void getPermissions() async {
    if (await Permissions.contactPermissionsGranted()) {
      contacts = getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  List<Contact> getAllContacts() {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<Contact> _contacts = _contactsProvider.contactList;
    //(await ContactsService.getContacts()).toList();
    print('\n\n\n HERE \n\n');
    _contacts.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    return _contacts;
    // if (mounted) {
    //   setState(() {
    //     contacts = _contacts;
    //   });
    // }
  }

  void filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
      ),
      body: Container(
        child: StreamBuilder<Iterable<Contact>>(
          stream: _contactsProvider.controller.stream,
          builder: (BuildContext context, snapshot) {
            // print(snapshot.hasData);
            // print(_contactsProvider.contactList);
            if (contacts != _contactsProvider.contactList) {
              contacts = getAllContacts();
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
                                    backgroundImage:
                                        MemoryImage(contact.avatar),
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
                                          style:
                                              TextStyle(color: Colors.white)),
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
      ),
    );
  }
}

class ContactDetails extends StatelessWidget {
  final AuthMethods _authMethods = AuthMethods();
  final SmsQuery query = new SmsQuery();
  final Sms.ContactQuery contacts = new Sms.ContactQuery();

  ContactDetails({
    Key key,
    @required this.color1,
    @required this.color2,
    @required this.contact,
  }) : super(key: key);

  final Color color1;
  final Color color2;
  final Contact contact;

  String formatNumber(String number) {
    if (number.length == 11 && number.startsWith('0')) {
      return '+234' + number.substring(1);
    }
    if (number.length == 14 && number.startsWith('+234')) {
      return number;
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color1,
                  color2,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Center(
              child: Text(
                contact.initials(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  contact.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 5),
          FutureBuilder<User>(
            initialData: null,
            future: _authMethods.getUserByPhone(
                formatNumber(contact.phones.elementAt(0).value)),
            builder: (context, snapshot) {
              UserProvider userProvider;
              userProvider = Provider.of<UserProvider>(context, listen: false);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: contact.phones.length,
                itemBuilder: (__, index) {
                  String number = contact.phones.elementAt(index).value;
                  return ListTile(
                    title: Text(number),
                    trailing: ButtonBar(
                      alignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.call),
                          color: Colors.white,
                          onPressed: () async {
                            debugPrint('CALLING');
                            await FlutterPhoneDirectCaller.callNumber(number);
                          },
                        ),
                        snapshot.data != null
                            ? IconButton(
                                icon: Icon(Icons.call),
                                color: color1,
                                onPressed: () async {
                                  User receiver = snapshot.data;
                                  if (await Permissions
                                      .cameraAndMicrophonePermissionsGranted())
                                    return CallUtils.dialAudio(
                                      from: userProvider.getUser,
                                      to: receiver,
                                      context: context,
                                    );
                                  return;
                                },
                              )
                            : Container(),
                        IconButton(
                          icon: Icon(Icons.message),
                          color: Colors.white,
                          onPressed: () async {
                            print("MESSAGING...");
                            List<SmsMessage> messages =
                                await query.querySms(address: number);
                            Sms.Contact contact =
                                await contacts.queryContact(number);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TextScreen(
                                  contact: contact,
                                  messages: messages,
                                ),
                              ),
                            );
                          },
                        ),
                        snapshot.data != null
                            ? IconButton(
                                icon: Icon(Icons.message),
                                color: color1,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatScreen(receiver: snapshot.data),
                                      ));
                                },
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
