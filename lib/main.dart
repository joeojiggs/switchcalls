import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/resources/firebase_repository.dart';
import 'package:switchcalls/screens/home_screen.dart';
import 'package:switchcalls/screens/login_screen.dart';
import 'package:switchcalls/screens/search_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseRepository _repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Switchcalls",
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/search_screen': (context) => SearchScreen(),
      },
      home: FutureBuilder(
        future: _repository.getCurrentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot ) {
          if(snapshot.hasData){
            return HomeScreen() ;
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}