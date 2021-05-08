import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/local_message_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/search_screen.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/skype_appbar.dart';

import '../widgets/new_chat_button.dart';
import '../widgets/select_contact.dart';
import '../../../widgets/user_details_container.dart';
import 'chat_list.dart';
import 'sms_list.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  AuthMethods _authMethods = AuthMethods();
  List<User> userList;
  TabController _tabCont;
  MessageProvider _messageProvider;

  bool isLoading = true;
  List<SmsThread> threads = [];

  Future<void> getThreads() async {
    try {
      threads = await _messageProvider.getthreads();
      isLoading = false;
      if (mounted) setState(() {});
    } catch (e) {
      print(e.toString());
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    _messageProvider = Provider.of<MessageProvider>(context, listen: false);
    // getThreads();
    _messageProvider.init();
    _tabCont = TabController(vsync: this, length: 2, initialIndex: 0);

    _authMethods.getCurrentUser().then((FirebaseUser user) {
      _authMethods.fetchAllUsers(user).then((List<User> list) {
        if (mounted) {
          setState(() {
            userList = list;
          });
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabCont.dispose();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant ChatListScreen oldWidget) {
  //   getThreads();
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      // create: (context) => new MessageListProvider(thisUser.uid),
      child: PickupLayout(
        scaffold: Scaffold(
          backgroundColor: UniversalVariables.blackColor,
          appBar: SkypeAppBar(
            title: 'Messages',
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
          floatingActionButton: NewChatButton(
            onTap: () async {
              if (_tabCont.index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchScreen(show: true)),
                );
              } else {
                //TODO: New Message for text messages
                // () =>
                await showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: UniversalVariables.blackColor,
                  builder: (context) => SelectContact(),
                );
              }
            },
          ),
          body: Column(
            children: [
              TabBar(
                controller: _tabCont,
                tabs: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Free Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Local Messages',
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
                  controller: _tabCont,
                  children: [
                    ChatList(), //controller: _messageListProvider?.controller),
                    SMSList(
                      isLoading: isLoading,
                      threads: threads,
                      messageProvider: _messageProvider,
                    ),
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
