import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:sms/contact.dart' as Sms;
import 'package:sms/sms.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/messages/views/message_screen.dart';
import 'package:switchcalls/screens/messages/views/text_message_screen.dart';
import 'package:switchcalls/utils/call_utilities.dart';
import 'package:switchcalls/utils/permissions.dart';

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
