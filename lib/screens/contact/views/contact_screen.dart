import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/screens/search_screen.dart';
import 'package:switchcalls/widgets/skype_appbar.dart';
import 'package:switchcalls/widgets/user_details_container.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/models/contact.dart';

import '../providers/contacts_screen_provider.dart';
import './local_contacts.dart';
import './identified_contacts.dart';

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<MyContact> contacts = [];
  List<MyContact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();
  ContactsProvider _contactsProvider;
  ContactsScreenProvider _provider = ContactsScreenProvider();

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
      List<MyContact> cts = await _provider.init();
      contacts = _provider.getAllContacts(
          cts ?? _contactsProvider.contactList, contactsColorMap);
      setState(() {});
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  void filterContacts() {
    List<MyContact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = _provider.flattenPhoneNumber(searchTerm);
        String contactName = contact.name.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.numbers.firstWhere((phn) {
          String phnFlattened = _provider.flattenPhoneNumber(phn);
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
    return ChangeNotifierProvider<ContactsScreenProvider>(
        create: (context) => ContactsScreenProvider(),
        builder: (context, child) {
          return Consumer<ContactsScreenProvider>(
            builder: (context, model, child) {
              return Scaffold(
                backgroundColor: UniversalVariables.blackColor,
                appBar: SkypeAppBar(
                  title: "Contacts",
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen(showAll: true)),
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (__) {
                        return [
                          PopupMenuItem(
                            child: Text('Profile'),
                            value: 0,
                          ),
                        ];
                      },
                      onSelected: (index) async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: UniversalVariables.blackColor,
                          builder: (context) => UserDetailsContainer(),
                        );
                      },
                    ),
                  ],
                ),
                body: DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              'Local Contacts',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              'Identified Contacts',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        indicatorColor: UniversalVariables.blueColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 5,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            LocalContacts(
                              contactsProvider: _contactsProvider,
                              contacts: contacts,
                              searchController: searchController,
                              isSearching: isSearching,
                              contactsFiltered: contactsFiltered,
                              contactsColorMap: contactsColorMap,
                              prefs: model.prefs,
                              provider: _provider,
                            ),
                            // Container()
                            IdentifiedContacts(
                              contacts: contacts,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
