import 'package:flutter/material.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/pageviews/logs/widgets/floating_column.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/skype_appbar.dart';

import 'widgets/log_list_container.dart';

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
              onPressed: () => Navigator.pushNamed(context, "/search_screen"),
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
                    LogListContainer(),
                    LogListContainer(isLocal: true),
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
