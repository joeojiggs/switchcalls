import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:shimmer/shimmer.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Stack(
        children: [
          Center(
            child: loginButton(),
          ),
          isLoginPressed
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container()
        ],
      ),
    );
  }

  Widget loginButton() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("WELCOME", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
          Padding(
            padding: EdgeInsets.all(5),
            child: Text("Please sign into Switch Calls with your Google Account", textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.5, fontWeight: FontWeight.w300, letterSpacing: 1.2),),
          ),
          Image.asset('assets/icon.png', height: 200,),
          Container(
            margin: EdgeInsets.all(30),
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  //topRight: Radius.circular(10),
                  //bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(25)
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            //decoration: BoxDecoration(
                //color: Colors.orange,
                //shape: BoxShape.rectangle,
                //borderRadius: BorderRadius.only(
                    //topLeft: Radius.circular(25.0),
                    //bottomRight: Radius.circular(25.0))),
            //color: Colors.amber,
            child: Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white,
              child: FlatButton(
                //shape: OutlineInputBorder(),
                padding: EdgeInsets.all(10),
                child: Text(
                  "SIGNIN",
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                onPressed: () => performLogin(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void performLogin() {
    print("tring to perform login");

    setState(() {
      isLoginPressed = true;
    });

    _authMethods.signIn().then((FirebaseUser user) {
      print("something");
      if (user != null) {
        authenticateUser(user);
      } else {
        print("There was an error");
      }
    });
  }

  void authenticateUser(FirebaseUser user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return HomeScreen();
              }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return HomeScreen();
            }));
      }
    });
  }
}
