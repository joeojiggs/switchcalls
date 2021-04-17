import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/resources/local_db/repository/log_repository.dart';
import 'package:switchcalls/utils/universal_variables.dart';

import 'home_screen.dart';
import 'auth/views/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserProvider userProvider;
  AuthMethods authMethods = AuthMethods();

  void decideNavigation() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    if (await authMethods.getCurrentUser() != null) {
      await userProvider.refreshUser();
      LogRepository.init(
        isHive: false,
        dbName: userProvider.getUser.uid,
      );
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      decideNavigation();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Center(
        child: Image.asset(
          'assets/icon.png',
          height: 200,
        ),
      ),
    );
  }
}
