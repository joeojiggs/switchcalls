import 'package:flutter/material.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:sms/contact.dart' as Cts;
import 'package:contacts_service/contacts_service.dart';
import 'package:provider/provider.dart';
import '../views/text_message_screen.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/provider/local_message_provider.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/models/contact.dart';
// import 'package:sms/contact.dart' as;

class SelectContact extends StatefulWidget {
  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  ContactsProvider _contactsProvider;
  final TextEditingController searchController = TextEditingController();
  List<MyContact> contactsFiltered = [];
  MessageProvider _messageProvider;
// List<Contact> contacts = [];

  @override
  void initState() {
    _contactsProvider = Provider.of<ContactsProvider>(context, listen: false);
    _messageProvider = Provider.of<MessageProvider>(context, listen: false);
    super.initState();
    searchController.addListener(() {
      setState(() {
        filterContacts();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    //false;
    // print(_contactsProvider.contactList.length);
    //  ;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: UniversalVariables.blackColor,
            leading: Container(),
            centerTitle: true,
            title: Text(
              'Select Contact',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [],
          ),
          ListTile(
            title: Text('New Number'),
            leading: Icon(Icons.phone_forwarded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextScreen(),
              ),
            ),
          ),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              border: new OutlineInputBorder(
                borderSide: new BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: isSearching == true
                  ? contactsFiltered.length
                  : _contactsProvider.contactList.length,
              itemBuilder: (__, index) {
                MyContact _contact = isSearching == true
                    ? contactsFiltered[index]
                    : _contactsProvider.contactList[index];
                return ListTile(
                  title: Text('${_contact.name}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _contact.trimNums
                        .map((e) => InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('$e'),
                              ),
                              onTap: () async {
                                if (_contact.trimNums.length > 1) {
                                  Cts.Contact contact = await Cts.ContactQuery()
                                      .queryContact(e);

                                  var test = _messageProvider.messages
                                      .firstWhere((element) {
                                    print(element.contact.address);
                                    print(contact.address.replaceAll(RegExp(r'\s'), ''));
                                    return element.contact.address.replaceAll(RegExp(r'\s'), '') ==
                                        contact.address
                                            .replaceAll(RegExp(r'\s'), '');
                                  }, orElse: () {
                                    print('None found');
                                    return;
                                  });
                                  List<SmsMessage> _messages = test?.messages;
                                  // await SmsQuery()
                                  //     .querySms(address: contact.address, kinds: [
                                  //   SmsQueryKind.Inbox,
                                  //   SmsQueryKind.Sent,
                                  //   SmsQueryKind.Draft,
                                  // ]);
                                  print(
                                      _messages?.map((e) => e.body)?.toList());
                                  // (await _messageProvider.getthreads())
                                  //     .where((element) =>
                                  //         element.contact.address == contact.address)
                                  //     .first
                                  //     .messages;

                                  if (_messages == null) {
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TextScreen(
                                        contact: contact,
                                        messages: _messages,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ))
                        .toList(),
                  ),
                  onTap: () async {
                    if (_contact.trimNums.length < 2) {
                      Cts.Contact contact = await Cts.ContactQuery()
                          .queryContact(_contact.trimNums.first);

                      var test =
                          _messageProvider.messages.firstWhere((element) {
                        print(element.contact.address);
                        print(contact.address.replaceAll(RegExp(r'\s'), ''));
                        return element.contact.address ==
                            contact.address.replaceAll(RegExp(r'\s'), '');
                      }, orElse: () {
                        print('None found');
                        return;
                      });
                      List<SmsMessage> _messages = test?.messages;
                      // await SmsQuery()
                      //     .querySms(address: contact.address, kinds: [
                      //   SmsQueryKind.Inbox,
                      //   SmsQueryKind.Sent,
                      //   SmsQueryKind.Draft,
                      // ]);
                      print(_messages?.map((e) => e.body)?.toList());
                      // (await _messageProvider.getthreads())
                      //     .where((element) =>
                      //         element.contact.address == contact.address)
                      //     .first
                      //     .messages;
                       if (_messages == null) {
                                    return;
                                  }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TextScreen(
                            contact: contact,
                            messages: _messages,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
              // isLoading: isLoading,
              // threads: messages,
            ),
          ),
        ],
      ),
    );
  }

  void filterContacts() {
    List<MyContact> _contacts = [];
    _contacts.addAll(_contactsProvider.contactList);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.name.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.numbers.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }
}
