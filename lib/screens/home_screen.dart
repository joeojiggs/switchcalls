import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/enum/user_state.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/resources/local_db/repository/log_repository.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/pageviews/contact/contact_screen.dart';
import 'package:switchcalls/screens/pageviews/messages/message_list_screen.dart';
import 'package:switchcalls/screens/pageviews/logs/log_screen.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController pageController;
  int _page = 0;
  final AuthMethods _authMethods = AuthMethods();

  UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authMethods.setUserState(
        userId: userProvider.getUser.uid,
        userState: UserState.Online,
      );

      LogRepository.init(
        isHive: false,
        dbName: userProvider.getUser.uid,
      );
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
}

