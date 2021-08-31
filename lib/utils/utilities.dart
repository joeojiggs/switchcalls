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
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/utils/location_utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

class Utils {
  static FlutterLibphonenumber numLib = FlutterLibphonenumber();

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
    PickedFile selectedImage =
        await ImagePicker().getImage(source: source, imageQuality: 60);
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

  static Future<File> cropImage(File image) async {
    return await ImageCropper.cropImage(
      sourcePath: image.path,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: UniversalVariables.blueColor,
        cropFrameColor: UniversalVariables.blueColor,
        activeControlsWidgetColor: UniversalVariables.blueColor,
      ),
      cropStyle: CropStyle.rectangle,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
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
    String num1 = number1.replaceAll(RegExp(r' '), '') ?? '';
    String num2 = number2?.replaceAll(RegExp(r' '), '') ?? '';
    return num1 == num2;
  }

  static Future<String> formatNum(String number, [bool to234 = false]) async {
    // print(number);
    Map<String, dynamic> res;
    String numb = number.replaceAll(RegExp(r' '), '');
    try {
      await numLib.init();
      //path 1
      if (numb.startsWith('+')) {
        print('Path 1');
        res = await numLib.parse(numb);
      }
      //path 2
      else if (numb.startsWith('0')) {
        print('Path 2');
        if (LocationUtils.loc?.countryCode == null) {
          await getCountryCode();
        }
        // print("LOC IS ${LocationUtils.loc?.countryCode}");
        res = await numLib.parse('${LocationUtils.loc?.countryCode}$numb');
      }
      // path 3
      else {
        print('Path 3');
        int ind = numb.indexOf('+');
        res = await numLib.parse('${numb.substring(ind)}');
      }
      // print(res);
      return (to234 ? res['e164'] : res['national'])
        ..toString()
        ..replaceAll(RegExp(r' '), '');
    } catch (e) {
      print(e);
      throw numb;
    }

    // numLib.String number = numb.replaceAll(new RegExp(r' '), '');
    // if (number.startsWith('+234')) {
    //   return number.replaceRange(0, 3, '0');
    // } else if (number.startsWith('234')) {
    //   return number.replaceRange(0, 2, '0');
    // } else
    //   return number;
  }

  static List<MyContact> cleanList(List<MyContact> cts) {
    cts.removeWhere((e) => e.name.isEmpty && e.numbers.isEmpty);
    return cts;
  }

  static void openFile(String path) {
    OpenFile.open(path);
  }

  static Future<void> getCountryCode() async {
    print('Country Code is null');
    Map<String, CountryWithPhoneCode> supRegs;
    if (LocationUtils.loc?.region == null) {
      print('Region is null');
      await LocationUtils.getCurrentLocation();
    }
    supRegs = await numLib.getAllSupportedRegions();
    supRegs.removeWhere(
      (key, value) => !key.startsWith(LocationUtils.loc?.region),
    );
    LocationUtils.loc.countryCode = supRegs.values.first.phoneCode;
  }

  static Future<String> getDir() async =>
      (await getExternalStorageDirectory()).path;
}
