import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/contact/providers/contacts_screen_provider.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/custom_tile.dart';

import 'messages/views/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool showAll;

  const SearchScreen({Key key, this.showAll = false}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods _authMethods = AuthMethods();
  ContactsProvider _contactsProvider;

  List<User> userList = [];
  String query = "";
  TextEditingController searchController = TextEditingController();
  List<User> suggestionList = [];

  @override
  void initState() {
    super.initState();
    _contactsProvider = Provider.of<ContactsProvider>(context, listen: false);

    _authMethods.getCurrentUser().then((FirebaseUser user) {
      _authMethods.fetchAllUsers(user).then((List<User> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  searchAppBar(BuildContext context) {
    return GradientAppBar(
      backgroundColorStart: UniversalVariables.gradientColorStart,
      backgroundColorEnd: UniversalVariables.gradientColorEnd,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  searchController.clear();
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    if (widget.showAll) {
      suggestionList = query.isEmpty
          ? userList
          : userList.where((User user) {
              String _getUsername = user.username.toLowerCase();
              String _query = query.toLowerCase();
              String _getName = user.name.toLowerCase();
              bool matchesUsername = _getUsername.contains(_query);
              bool matchesName = _getName.contains(_query);

              return (matchesUsername || matchesName);

              // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
              //     (user.name.toLowerCase().contains(query.toLowerCase()))),
            }).toList();
    } else {
      suggestionList = query.isEmpty
          ? []
          : userList.where((User user) {
              String _getUsername = user.username.toLowerCase();
              String _query = query.toLowerCase();
              String _getName = user.name.toLowerCase();
              bool matchesUsername = _getUsername.contains(_query);
              bool matchesName = _getName.contains(_query);

              return (matchesUsername || matchesName);

              // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
              //     (user.name.toLowerCase().contains(query.toLowerCase()))),
            }).toList();
    }

    return ListView.builder(
      itemCount: suggestionList?.length,
      itemBuilder: ((context, index) {
        User searchedUser = User(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username);

        return CustomTile(
          mini: false,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          receiver: searchedUser,
                        )));
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(searchedUser.profilePhoto),
            backgroundColor: Colors.grey,
          ),
          title: Text(
            searchedUser.username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            searchedUser.name,
            style: TextStyle(color: UniversalVariables.greyColor),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactsScreenProvider>(
      create: (context) => ContactsScreenProvider(),
      builder: (context, snapshot) {
        return Consumer<ContactsScreenProvider>(
          builder: (context, model, child) {
            // userList = model.filterIdentifiedCL(
            //     userList, _contactsProvider.contactList, searchController.text);
            print(userList.length);
            return Scaffold(
              backgroundColor: UniversalVariables.blackColor,
              appBar: searchAppBar(context),
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: buildSuggestions(query),
              ),
            );
          },
        );
      },
    );
  }
}

//  return ListView.builder(
//       itemCount: suggestionList.length,
//       itemBuilder: ((context, index) {
//         User searchedUser = User(
//             uid: suggestionList[index].uid,
//             profilePhoto: suggestionList[index].profilePhoto,
//             name: suggestionList[index].name,
//             username: suggestionList[index].username);

//         return CustomTile(
//           mini: false,
//           onTap: () {;
//           },
//           leading: CircleAvatar(
//             backgroundImage: NetworkImage(searchedUser.profilePhoto),
//             backgroundColor: Colors.grey,
//           ),
//           title: Text(
//             searchedUser.username,
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           subtitle: Text(
//             searchedUser.name,
//             style: TextStyle(color: UniversalVariables.greyColor),
//           ),
//         );
//       }),
//     );
