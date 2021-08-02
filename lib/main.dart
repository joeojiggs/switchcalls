import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/contacts_provider.dart';
import 'package:switchcalls/provider/image_upload_provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/screens/search_screen.dart';

import 'provider/agora_provider.dart';
import 'provider/local_log_provider.dart';
import 'provider/local_message_provider.dart';
import 'screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(lazy: true, create: (_) => UserProvider()),
        ChangeNotifierProvider(lazy: true, create: (_) => ContactsProvider()),
        ChangeNotifierProvider(lazy: true, create: (_) => LogsProvider()),
        ChangeNotifierProvider(lazy: true, create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => AgoraProvider()),
      ],
      child: MaterialApp(
        title: "Switch Calls",
        debugShowCheckedModeBanner: true,
        initialRoute: '/',
        routes: {
          '/search_screen': (context) => SearchScreen(),
        },
        theme: ThemeData(brightness: Brightness.dark),
        home: SplashScreen(),
      ),
    ); 
  }
}

/*
  CURRENT TODOS
  // Let all permissions be asked for at the beginning
  // Remove box in contact screen
  // Add menu in call section
  // Delivery receipt for free messages
Arrrange free messages 
  // calls according to date
    //contact screen
    // free call screen update after call 
    // editable user name
    // xicon in search screen
//Notifications
    //remove schedule and polls
    //remove quieyt box when searchngb in local call section
*/
