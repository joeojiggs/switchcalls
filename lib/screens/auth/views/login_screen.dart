import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:shimmer/shimmer.dart';
import 'package:switchcalls/screens/auth/providers/login_provider.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginProvider>(
        create: (context) => LoginProvider(context),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: UniversalVariables.blackColor,
            body: Stack(
              children: [
                Center(
                  child: Consumer<LoginProvider>(
                    builder: (context, model, child) {
                      return loginButton(model);
                    },
                  ),
                ),
                Consumer<LoginProvider>(
                  builder: (context, model, child) {
                    return model.isLoginPressed
                        ? Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black26,
                          child: Center(
                              child: CircularProgressIndicator(),
                            ),
                        )
                        : Container();
                  },
                )
              ],
            ),
          );
        });
  }

  Widget loginButton(LoginProvider model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "WELCOME",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    model.showPin
                        ? "Please sign into Switch Calls with your Phone Number"
                        : "Please add your google account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2),
                  ),
                ),
                Image.asset(
                  'assets/icon.png',
                  height: 200,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Form(
              key: model.key,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      model.showPin
                          ? TextFormField(
                              controller: model.phoneNumController,
                              focusNode: model.phoneNumberFocus,
                              keyboardType: TextInputType.phone,
                              validator: model.showPhone
                                  ? model.validatePhone
                                  : model.validatePin,
                              decoration: InputDecoration(
                                hintText:
                                    model.showPhone ? 'Phone Number' : 'Pin',
                                filled: true,
                                // fillColor:
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(),
                              ),
                            )
                          : Container(),
                      Container(
                        margin: EdgeInsets.all(30),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.white,
                          child: FlatButton(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              model.showPhone
                                  ? "SIGNIN"
                                  : model.showPin
                                      ? 'PROCEED'
                                      : 'ADD GOOGLE MAIL',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            onPressed: () => model.showPhone
                                ? model.getStarted()
                                : model.showPin
                                    ? model.verifyOtp()
                                    : model.addGoogleAccount(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

    // _authMethods.signIn().then((FirebaseUser user) {
    //   print("something");
    //   if (user != null) {
    //     authenticateUser(user);
    //   } else {
    //     print("There was an error");
    //   }
    // });
  }

  void authenticateUser(FirebaseUser user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      // if (isNewUser) {
      //   _authMethods.addDataToDb(user).then((value) {
      //     Navigator.pushReplacement(context,
      //         MaterialPageRoute(builder: (context) {
      //       return HomeScreen();
      //     }));
      //   });
      // } else {
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (context) {
      //     return HomeScreen();
      //   }));
      // }
    });
  }
}
