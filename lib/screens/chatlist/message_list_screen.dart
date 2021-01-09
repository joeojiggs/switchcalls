import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/models/contact.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/calls/chat_methods.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/chatlist/views/text_message_screen.dart';
import 'package:switchcalls/screens/chatlist/widgets/contact_view.dart';
import 'package:switchcalls/widgets/quiet_box.dart';
import 'package:switchcalls/screens/chatlist/widgets/user_circle.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/custom_tile.dart';
import 'package:switchcalls/widgets/skype_appbar.dart';

import 'widgets/new_chat_button.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: UserCircle(),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/search_screen");
              },
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: NewChatButton(),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(Icons.network_locked),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(Icons.network_cell),
                  ),
                ],
                indicatorColor: UniversalVariables.blueColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 5,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ChatListContainer(),
                    LocalChatLisContainer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocalChatLisContainer extends StatefulWidget {
  @override
  _LocalChatLisContainerState createState() => _LocalChatLisContainerState();
}

class _LocalChatLisContainerState extends State<LocalChatLisContainer> {
  final SmsQuery query = new SmsQuery();
  SmsSender sender = new SmsSender();

  Future<List<SmsThread>> getthreads() async {
    try {
      return await query.getAllThreads;
    } on Exception catch (e) {
      print(e.toString());
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<SmsThread>>(
        future: getthreads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Getting');
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(
              child: Icon(Icons.cancel, size: 80),
            );
          if (snapshot.hasData) {
            List<SmsThread> threads = snapshot.data;
            return ListView.builder(
              itemCount: threads.length,
              itemBuilder: (__, index) {
                SmsThread _thread = threads[index];
                return CustomTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextScreen(thread: _thread),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(
                      Random().nextInt(255),
                      Random().nextInt(255),
                      Random().nextInt(255),
                      0.5,
                    ),
                    radius: 30,
                    child: _thread.contact.photo != null
                        ? Image.memory(_thread.contact.photo?.bytes)
                        : _thread.contact?.fullName?.isNotEmpty ?? false
                            ? Text(
                                _thread.contact.fullName[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: UniversalVariables.lightBlueColor,
                                  fontSize: 18,
                                ),
                              )
                            : Text(
                                _thread.contact.address[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: UniversalVariables.lightBlueColor,
                                  fontSize: 18,
                                ),
                              ),
                  ),
                  title: Text(
                    _thread.contact.fullName ?? _thread.contact.address,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    _thread.messages[0].body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  // trailing: IconButton(
                  //   icon: Icon(Icons.message),
                  //   onPressed: () {},
                  // ),
                );
              },
            );
          }
          return QuietBox();
        },
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _chatMethods.fetchContacts(
        userId: userProvider.getUser.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.documents;

          if (docList.isEmpty) {
            return QuietBox();
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: docList.length,
            itemBuilder: (context, index) {
              Contact contact = Contact.fromMap(docList[index].data);

              return ContactView(contact);
            },
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
