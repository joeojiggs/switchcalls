import 'package:flutter/material.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/logs/widgets/floating_column.dart';
import 'package:switchcalls/screens/search_screen.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/skype_appbar.dart';
import 'package:switchcalls/widgets/user_details_container.dart';

import 'views/local_log_list_container.dart';
import 'views/log_list_container.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: "Calls",
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
        floatingActionButton: FloatingColumn(),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Free Calls',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Local Calls',
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
                    LogListContainer(),
                    LocalLogListContainer(),
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
