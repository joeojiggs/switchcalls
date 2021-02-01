import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/auth/views/signup.dart';

import '../../home_screen.dart';

class LoginProvider extends ChangeNotifier {
  LoginProvider(this.context);

  //
  final BuildContext context;
  final AuthMethods _authMethods = AuthMethods();
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  TextEditingController phoneNumController = TextEditingController();
  TextEditingController pin1 = TextEditingController();
  TextEditingController pin2 = TextEditingController();
  TextEditingController pin3 = TextEditingController();
  TextEditingController pin4 = TextEditingController();
  TextEditingController pin5 = TextEditingController();
  TextEditingController pin6 = TextEditingController();

  bool isLoginPressed = false;
  bool showPhone = true;
  bool showPin = true;
  bool showGoogle = true;

  FocusNode phoneNumberFocus = FocusNode();
  String verificationId;
  int forceResendingToken;
  String otpCode = "";
  var key = GlobalKey<FormState>();

  String validatePhone(String value) {
    if (phoneNumController.text.length == 0) {
      return 'Please enter your phone number';
    }
    if (phoneNumController.text.length < 11) {
      return "Please enter a valid phone number";
    }
    if (!phoneNumController.text.startsWith("0")) {
      return "Invalid phone number format";
    }
    return null;
  }

  String validatePin(String value) {
    if (phoneNumController.text.length == 0) {
      return 'Please enter pin';
    }
    if (phoneNumController.text.length < 11) {
      return "Please enter a valid pin";
    }
    return null;
  }

  void showLoader() {
    isLoginPressed = !isLoginPressed;
    notifyListeners();
  }

  void getStarted() async {
    try {
      phoneNumberFocus.unfocus();
      String phoneNumber = phoneNumController.text;

      print(phoneNumber);

      showLoader();

      String formattedPhone = phoneNumber.substring(1, phoneNumber.length);
      phoneNumber = "+234$formattedPhone";

      phoneNumberFocus.unfocus();

      // phoneNumber ="+2348036007161";

      auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 10),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        forceResendingToken: forceResendingToken,
      );
    } catch (e) {
      print(e.toString());
      showLoader();
    }
  }

  void codeSent(String verificationId, [int forceResendingToken]) {
    otpCode = "";
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    showPhone = false;
    phoneNumController.clear();
    if (isLoginPressed) {
      showLoader();
    }
  }

  void codeAutoRetrievalTimeout(String id) {}

  void verificationCompleted(AuthCredential credential) async {
    showLoader();

    await auth.signInWithCredential(credential);

    FirebaseUser user = await auth.currentUser();

    if (user != null) {
      readUserData(user);
    }
  }

  Future<void> verificationFailed(AuthException e) async {
    if (isLoginPressed) {
      showLoader();
    }

    print("Exception thrown $e");
    _showSnackBar(message: 'Unable to verify phone number');
  }

  void verifyOtp() async {
    if (otpCode.length < 6) {
      _showSnackBar(message: "Please enter complete OTP code");
      return;
    }

    showLoader();

    // await Future.delayed(Duration(seconds: 3));

    AuthCredential credential;

    try {
      credential = PhoneAuthProvider.getCredential(
          verificationId: verificationId, smsCode: otpCode);
      await auth.signInWithCredential(credential);
    } catch (e) {
      if (isLoginPressed) {
        showLoader();
      }
      print(e);
      _showSnackBar(message: "Unable to verify your number");
      return;
    }

    FirebaseUser user = await auth.currentUser();

    if (user != null) {
      readUserData(user);
    } else {
      if (isLoginPressed) {
        showLoader();
      }

      _showSnackBar(message: "Unable to verify your number");
    }
  }

  Future<void> addGoogleAccount() async {
    User user = await _authMethods.addGoogleAcct();
    if (user == null) {
      return;
    }
    _authMethods.addDataToDb(user).then((value) => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) {
          return HomeScreen();
        })));
  }

  void readUserData(FirebaseUser user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        showPin = false;

        if (isLoginPressed) {
          showLoader();
        }

        // _authMethods.addDataToDb(user).then((value) {
        //   Navigator.pushReplacement(context,
        //       MaterialPageRoute(builder: (context) {
        //     return HomeScreen();
        //   }));
        // });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }

  SnackBar _showSnackBar({String message}) {
    return SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ));
  }
}
