import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:switchcalls/enum/user_state.dart';
import 'package:open_file/open_file.dart';
import 'package:switchcalls/models/contact.dart';
//import 'package:switchcalls/resources/auth_methods.dart';

class Utils {
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }

  static String toCamelCase(String name) {
    List<String> nameSplit = name.split(" ");
    nameSplit.map((e) => e.substring(0, 1) + e.substring(1)).toList();

    return nameSplit.join(" ");
  }

  // this is new

  static Future<File> pickImage({@required ImageSource source}) async {
    PickedFile selectedImage = await ImagePicker().getImage(
      source: source,
    );
    if (selectedImage != null)
      return await compressImage(File(selectedImage.path));
    else
      return null;
  }

  static Future<File> compressImage(File imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);

    return new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline:
        return 0;

      case UserState.Online:
        return 1;

      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.Offline;

      case 1:
        return UserState.Online;

      default:
        return UserState.Waiting;
    }
  }

  static String formatDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    var timeformat = DateFormat.jm();
    return formatter.format(dateTime) + '    ' + timeformat.format(dateTime);
  }

  static String convertTimeStampToHumanDate(int timeStamp) {
    var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return DateFormat('dd/MM/yyyy').format(dateToTimeStamp);
  }

  static String convertTimeStampToHumanHour(int timeStamp) {
    var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return DateFormat('HH:mm').format(dateToTimeStamp);
  }

  static bool compareNumbers(String number1, String number2) {
    String num1 = formatNum(number1);
    String num2 = formatNum(number2);
    return num1 == num2 ? true : false;
  }

  static String formatNum(String numb, [bool to234 = false]) {
    String number = numb.replaceAll(new RegExp(r' '), '');
    if (number.startsWith('+234')) {
      return number.replaceRange(0, 3, '0');
    } else if (number.startsWith('234')) {
      return number.replaceRange(0, 2, '0');
    } else
      return number;
  }

  static List<MyContact> cleanList(List<MyContact> cts) {
    cts.removeWhere((e) => e.name.isEmpty && e.numbers.isEmpty);
    return cts;
  }

  static void openFile(String path) {
    OpenFile.open(path);
  }

  static Future<String> getDir() async =>
      (await getExternalStorageDirectory()).path;
}
