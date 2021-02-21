import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/enum/user_state.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/provider/local_log_provider.dart';
import 'package:switchcalls/provider/local_message_provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/resources/local_db/repository/log_repository.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/messages/message_list_screen.dart';
import 'package:switchcalls/screens/logs/log_screen.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/utils/universal_variables.dart';

import 'contact/contact_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  TextEditingController _textEditingController;
  PageController pageController;
  int _page = 0;
  final AuthMethods _authMethods = AuthMethods();
  SmsReceiver receiver = new SmsReceiver();
  StreamSubscription<SmsMessage> receivedSub;

  UserProvider userProvider;
  ContactsProvider contactsProvider;
  LogsProvider logsProvider;

  @override
  void initState() {
    super.initState();
    loadApp();
    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
    _textEditingController = TextEditingController();
  }

  Future<void> loadApp() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();

    LogRepository.init(
      isHive: false,
      dbName: userProvider.getUser.uid,
    );

    await Permissions.askNecessaryPermissions();

    _authMethods.setUserState(
      userId: userProvider.getUser.uid,
      userState: UserState.Online,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      contactsProvider = Provider.of<ContactsProvider>(context, listen: false);
      logsProvider = Provider.of<LogsProvider>(context, listen: false);
      contactsProvider.init(true);
      receivedSub = receiver.onSmsReceived.listen((SmsMessage msg) {
        print('NOTIFICATION\n${msg.address} sent you a message.');
        setState(() {});
      });

      if (userProvider.getUser.phoneNumber == null) {
        await Future.delayed(Duration(seconds: 10));
        await addPhoneDialog(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    contactsProvider.close();
    logsProvider.close();
    //TODO: this isnt supposed to be cancelled, Fix it.
    receivedSub.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.uid
            : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    double _labelFontSize = 10;

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: PageView(
          children: <Widget>[
            LogScreen(),
            ChatListScreen(),
            ContactListScreen(title: 'Contacts'),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: UniversalVariables.blackColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.call,
                      color: (_page == 0)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor),
                  title: Text(
                    "Calls",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 0)
                            ? UniversalVariables.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat,
                      color: (_page == 1)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor),
                  title: Text(
                    "Messages",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 1)
                            ? UniversalVariables.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.contact_phone,
                      color: (_page == 2)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor),
                  title: Text(
                    "Contacts",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 2)
                            ? UniversalVariables.lightBlueColor
                            : Colors.grey),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }

  Future<Widget> addPhoneDialog(BuildContext context) async {
    final key = GlobalKey<FormState>();
    return await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            _textEditingController.clear();
            return true;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: UniversalVariables.separatorColor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 35, horizontal: 20),
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Phone Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Please add your 11 digit phone number to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.center,
                      validator: (val) => val.length != 0
                          ? val.length != 11
                              ? 'Please Enter a valid phone number'
                              : null
                          : 'Please enter your phone number',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: UniversalVariables.blueColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: UniversalVariables.blueColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    FlatButton(
                      color: UniversalVariables.lightBlueColor,
                      child: Text('CONTINUE'),
                      onPressed: () async {
                        if (key.currentState.validate()) {
                          await _authMethods
                              .updatePhoneNumber(_textEditingController.text);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Is the ui complete
// What kind of call is supposed to be made when a number is dialled, same with messages
