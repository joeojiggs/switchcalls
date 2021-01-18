import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/resources/auth_methods.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthMethods _authMethods = AuthMethods();

  void decideNavigation() async {
    FirebaseUser user = await _authMethods.getCurrentUser();
    await Future.delayed(Duration(seconds: 1));
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void initState() {
    decideNavigation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/icon.png',
          height: 200,
        ),
      ),
    );
  }
}
