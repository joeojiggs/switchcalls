import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:contacts_service/contacts_service.dart';

class DialScreen extends StatefulWidget {
  @override
  _DialScreenState createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  TextEditingController controller = TextEditingController();
  String phoneNumber = '';
  Map<String, Color> contactsColorMap = new Map();
  ContactsProvider _contacts;
  Iterable<Contact> _contactList;

  @override
  void initState() {
    _contacts = Provider.of<ContactsProvider>(context, listen: false);
    _contacts.resume();
    setState(() {
      _contactList = _contacts.contactList;
      getAllContacts(_contacts.contactList.toList());
      // print(_contacts.contactList);
    });

    controller.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    _contacts.pause();
    controller.dispose();
    super.dispose();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  List<Contact> getAllContacts(List<Contact> value) {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<Contact> _contacts = value;
    // print('\n\n\n HERE \n\n');
    _contacts?.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    // return _contacts;
    if (mounted) {
      setState(() {
        _contactList = _contacts;
      });
    }
  }

  filterContacts(List<Contact> contacts) {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts ?? []);
    if (controller.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = controller.text.toLowerCase();
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
    // return _contacts;
    setState(() {
      _contactList = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // getAllContacts(_contacts.contactList.toList());
    filterContacts(_contacts.contactList.toList());
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: false,
    //   builder: (context) => _buildDialer(),
    // );
    return Scaffold(
      body: Container(
        // color: UniversalVariables.blackColor,
        child: Stack(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: _contactList?.length ?? 0,
              itemBuilder: (context, index) {
                Contact contact = _contactList.toList()[index];

                var baseColor =
                    contactsColorMap[contact.displayName] as dynamic;
                Color color1 = baseColor[800];
                Color color2 = baseColor[400];
                return ListTile(
                  onTap: () async {
                    debugPrint('CALLING');
                    await FlutterPhoneDirectCaller.callNumber(
                        contact.phones.elementAt(0).value);
                    controller.clear();
                  },
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.length > 0
                      ? contact.phones.elementAt(0).value
                      : ''),
                  leading: (contact.avatar != null && contact.avatar.length > 0)
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
                );
              },
            ),
            _buildDialer(),
          ],
        ),
      ),
    );
  }

  Column _buildDialer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(flex: 5),
        Expanded(
          flex: 7,
          child: Container(
            color: UniversalVariables.blackColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: TextField(
                    readOnly: true,
                    controller: controller,
                    textAlign: TextAlign.center,
                    // inputFormatters: [maskFormatter],
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.backspace),
                        color: UniversalVariables.greyColor,
                        onPressed: () {
                          int len = controller.text.length;
                          if (len > 0)
                            controller.text =
                                controller.text.substring(0, len - 1);
                          setState(() {});
                        },
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    _buildCallDigits('1', controller),
                    _buildCallDigits('2', controller),
                    _buildCallDigits('3', controller),
                  ],
                ),
                Row(
                  children: [
                    _buildCallDigits('4', controller),
                    _buildCallDigits('5', controller),
                    _buildCallDigits('6', controller),
                  ],
                ),
                Row(
                  children: [
                    _buildCallDigits('7', controller),
                    _buildCallDigits('8', controller),
                    _buildCallDigits('9', controller),
                  ],
                ),
                Row(
                  children: [
                    _buildCallDigits('*', controller),
                    _buildCallDigits('0', controller),
                    _buildCallDigits('#', controller),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            // width: double.infinity,
            // height: double.infinity,
            alignment: Alignment.center,
            color: UniversalVariables.blackColor,
            child: Card(
              shape: CircleBorder(),
              elevation: 20,
              child: GestureDetector(
                onTap: () async {
                  debugPrint('CALLING');
                  await FlutterPhoneDirectCaller.callNumber(controller.text);
                  controller.clear();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: UniversalVariables.fabGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Icon(
                      Icons.call,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // DialPad(
  //   enableDtmf: true,
  //   dialButtonIconColor: UniversalVariables.blueColor,
  //   buttonTextColor: Colors.white,
  //   backspaceButtonIconColor: Colors.white,
  //   buttonColor: UniversalVariables.senderColor,
  // ),
  Expanded _buildCallDigits(String digit, TextEditingController control) {
    return Expanded(
      child: InkWell(
        onTap: () {
          control.text = control.text + digit;
          setState(() {});
        },
        child: Container(
          height: 80,
          // color: Colors.red,
          alignment: Alignment.center,
          child: Text(
            digit.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// StreamBuilder<Iterable<Contact>>(
//               stream: _contacts.controller.stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting)
//                   return Center(child: CircularProgressIndicator());
//                 if (snapshot.data == null) return Container();
//                 List<Contact> contacts = getAllContacts(snapshot.data.toList());
//                 {
//                   if (controller.text != null)
//                     contacts = filterContacts(contacts);
//                   else {
//                     contacts = [];
//                   }
//                 }
//                 return ;
//               },
//             ),
