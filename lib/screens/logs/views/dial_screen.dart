import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:switchcalls/models/contact.dart';

class DialScreen extends StatefulWidget {
  @override
  _DialScreenState createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  AuthMethods authMethods = AuthMethods();
  TextEditingController controller = TextEditingController();
  String phoneNumber = '';
  Map<String, Color> contactsColorMap = new Map();
  ContactsProvider _contacts;
  List<MyContact> _contactList = [];

  @override
  void initState() {
    _contacts = Provider.of<ContactsProvider>(context, listen: false);
    _contacts.resume();
    controller.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    _contacts.pause();
    controller.dispose();
    super.dispose();
  }

  String formatNumber(String number) {
    if (number.length == 11 && number.startsWith('0')) {
      return '+234' + number.substring(1);
    }
    if (number.length == 14 && number.startsWith('+234')) {
      return number;
    }
    return number;
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  List<MyContact> getAllContacts(List<MyContact> value) {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<MyContact> _contacts = value;
    // print('\n\n\n HERE \n\n');
    _contacts?.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.name] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    return _contacts;
    // if (mounted) {
    //   setState(() {
    //     _contactList = _contacts;
    //   });
    // }
  }

  void filterContacts(List<MyContact> contacts) {
    List<MyContact> _contacts = [];
    _contacts.addAll(contacts);
    if (controller.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = controller.text.toLowerCase();
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
    // return _contacts;
    // setState(() {
    _contactList = getAllContacts(_contacts);
    // print(_contactList);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        body: Container(
          // color: UniversalVariables.blackColor,
          child: Stack(
            children: [
              controller.text.length < 1
                  ? Container()
                  : controller.text.length > 0 && _contactList.length < 1
                      ? SafeArea(
                          child: ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Add to Contacts'),
                            onTap: () {
                              //TODO: Add contacts feature
                              print('You tapped me! Whyyy???');
                            },
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _contactList.length,
                          itemBuilder: (context, index) {
                            MyContact contact = _contactList[index];

                            var baseColor =
                                contactsColorMap[contact.name] as dynamic;
                            Color color1 = baseColor[800];
                            Color color2 = baseColor[400];
                            return ListTile(
                              onTap: () async {
                                debugPrint('CALLING');
                                await FlutterPhoneDirectCaller.callNumber(
                                    contact.numbers.elementAt(0));
                                controller.clear();
                              },
                              title: Text(contact.name),
                              subtitle: Text(
                                contact.numbers.length > 0
                                    ? contact.numbers.elementAt(0)
                                    : '',
                              ),
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
                                          end: Alignment.topRight,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        child: Text(
                                          contact.initials,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                              trailing: FutureBuilder<User>(
                                initialData: null,
                                future: authMethods.getUserByPhone(
                                    formatNumber(contact.numbers.elementAt(0))),
                                builder: (context, snapshot) {
                                  return Container(
                                    child: Padding(
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.call,
                                        size: 30,
                                        color: snapshot.data != null
                                            ? UniversalVariables.blueColor
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
              _buildDialer(),
            ],
          ),
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
                    showCursor: true,
                    controller: controller,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    onChanged: (val) => filterContacts(_contacts.contactList),
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          int len = controller.text.length;
                          if (len > 0)
                            controller.text =
                                controller.text.substring(0, len - 1);
                          setState(() {
                            filterContacts(_contacts.contactList);
                          });
                        },
                        onLongPress: () {
                          int len = controller.text.length;
                          if (len > 0) controller.clear();
                          setState(() {
                            filterContacts(_contacts.contactList);
                          });
                        },
                        child: IgnorePointer(
                          ignoring: true,
                          child: IconButton(
                            icon: Icon(Icons.backspace),
                            color: UniversalVariables.greyColor,
                            onPressed: () {},
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Divider(),
                Flexible(
                  child: Row(
                    children: [
                      _buildCallDigits('1', controller),
                      _buildCallDigits('2', controller, "A B C"),
                      _buildCallDigits('3', controller, "D E F"),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      _buildCallDigits('4', controller, "G H I"),
                      _buildCallDigits('5', controller, "J K L"),
                      _buildCallDigits('6', controller, "M N O"),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      _buildCallDigits('7', controller, "P Q R S"),
                      _buildCallDigits('8', controller, "T U V"),
                      _buildCallDigits('9', controller, "W X Y Z"),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      _buildCallDigits('*', controller),
                      _buildCallDigits('0', controller, '+', true),
                      _buildCallDigits('#', controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
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
                    padding: EdgeInsets.all(20.0),
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

  Expanded _buildCallDigits(String digit, TextEditingController control,
      [String subtitle = '', bool press = false]) {
    return Expanded(
      child: InkWell(
        onTap: () {
          control.text = control.text + digit;
          setState(() {
            filterContacts(_contacts.contactList.toList());
          });
        },
        onLongPress: () {
          if (press) {
            control.text = control.text + subtitle;
            setState(() {
              filterContacts(_contacts.contactList.toList());
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
