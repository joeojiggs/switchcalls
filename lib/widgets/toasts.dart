import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toasts {
  static FToast fToast;

  static init(BuildContext ctx) {
    if (fToast == null) {
      fToast = FToast();
      fToast.init(ctx);
    }
  }

  static Future<bool> error(String message) async {
    return await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  success() {}
  regular() {}
}
