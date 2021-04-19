import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/widgets/toasts.dart';
import 'package:switchcalls/utils/validator.dart';
import 'package:switchcalls/utils/universal_variables.dart';

import '../../home_screen.dart';

class LoginProvider extends ChangeNotifier with FormValidator {
  LoginProvider(this.context);

  //
  final BuildContext context;
  final AuthMethods _authMethods = AuthMethods();
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  TextEditingController phoneNumController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  String dialCode = '+234';

  bool isLoginPressed = false;
  bool showPhone = true;
  bool showPin = true;
  bool showGoogle = true;

  FocusNode phoneNumberFocus = FocusNode();
  String verificationId;
  int forceResendingToken;
  String otpCode = "";
  var key = GlobalKey<FormState>();

  void showLoader() {
    isLoginPressed = !isLoginPressed;
    notifyListeners();
  }

  // String formatPhoneNum(String phone) {
  //   if (phone.startsWith('0')) {
  //     return phone.substring(1, phone.length);
  //   }
  //   return phone;
  // }

  void getStarted() async {
    try {
      if (!key.currentState.validate()) {
        return;
      }

      String phoneNumber = phoneNumController.text;

      showLoader();

      phoneNumber = "$dialCode$phoneNumber";

      phoneNumberFocus.unfocus();

      print(phoneNumber);

      // phoneNumber = "+234810283438";

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
    // phoneNumController.clear();
    if (isLoginPressed) {
      showLoader();
    }
  }

  void codeAutoRetrievalTimeout(String id) {}

  void verificationCompleted(AuthCredential credential) async {
    try {
      showLoader();

      await auth.signInWithCredential(credential);

      FirebaseUser user = await auth.currentUser();

      if (user != null) {
        readUserData(user);
      }
    } catch (e) {
      print("ERROR:" + e.toString());
      showLoader();
      _showSnackBar(message: 'Unable to verify phone number');
      Toasts.error('Unable to verify phone number');
    }
  }

  Future<void> verificationFailed(AuthException e) async {
    if (isLoginPressed) {
      showLoader();
    }

    print("Exception thrown ${e.code}");
    if (e.code == 'invalidCredential') {
      _showSnackBar(message: 'Invalid phone number');
      Toasts.error('Invalid phone number');
    } else {
      _showSnackBar(message: 'Unable to verify phone number');
      Toasts.error('Unable to verify phone number');
    }
  }

  void verifyOtp() async {
    if (!key.currentState.validate()) {
      return;
    }

    phoneNumberFocus.unfocus();

    showLoader();

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
      Toasts.error('Unable to verify phone number');
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
    try {
      User user = await _authMethods.addGoogleAcct();
      if (user == null) {
        return;
      }
      _authMethods.addDataToDb(user).then((value) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) {
            return HomeScreen();
          })));
    } catch (e) {
      Toasts.error('Error adding Google Account');
    }
  }

  void readUserData(FirebaseUser user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        showPin = false;

        if (isLoginPressed) {
          showLoader();
        }
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
      margin: EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
      backgroundColor: UniversalVariables.senderColor,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<bool> pop() {
    if (showPhone == true && isLoginPressed == false) {
      return Future.value(true);
    }

    if (isLoginPressed == true) {
      isLoginPressed = false;
    } else if (showGoogle == false) {
      showGoogle = true;
    } else if (showPin == false) {
      showPin = true;
    } else if (showPhone == false) {
      showPhone = true;
    }
    notifyListeners();
    return Future.value(false);
  }
}
