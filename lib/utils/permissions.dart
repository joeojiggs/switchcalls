import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/services.dart';

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionsGranted() async {
    PermissionStatus cameraPermissionStatus = await _getCameraPermission();
    PermissionStatus microphonePermissionStatus =
        await _getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus);
      return false;
    }
  }

  static Future<bool> contactPermissionsGranted() async {
    PermissionStatus contactPermissionStatus = await _getContactPermission();
    PermissionStatus phonePermissionStatus = await _getPhonePermission();

    if (contactPermissionStatus == PermissionStatus.granted &&
        phonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions2(contactPermissionStatus);
      return false;
    }
  }

  static Future<bool> smsPermissionsGranted() async {
    PermissionStatus smsPermissionStatus = await _getSmsPermission();

    if (smsPermissionStatus == PermissionStatus.granted ) {
      return true;
    } else {
      _handleInvalidPermissions2(smsPermissionStatus);
      return false;
    }
  }

  static Future<PermissionStatus> _getCameraPermission() async {
    bool permission = await Permission.camera.isGranted;
    if (!permission) {
      await Permission.camera.request();
    }
    return await Permission.camera.status;
  }

  static Future<PermissionStatus> _getPhonePermission() async {
    bool permission = await Permission.phone.isGranted;
    if (!permission) {
      await Permission.camera.request();
    }
    return await Permission.camera.status;
  }

  static Future<PermissionStatus> _getSmsPermission() async {
    bool permission = await Permission.sms.isGranted;
    if (!permission) {
      await Permission.camera.request();
    }
    return await Permission.camera.status;
  }

  static Future<PermissionStatus> _getMicrophonePermission() async {
    bool permission = await Permission.microphone.isGranted;
    if (!permission) {
      await Permission.microphone.request();
    }
    return await Permission.microphone.status;
  }

  static Future<PermissionStatus> _getContactPermission() async {
    bool permission = await Permission.contacts.isGranted;
    if (!permission) {
      await Permission.contacts.request();
    }
    return await Permission.contacts.status;
  }

  static void _handleInvalidPermissions(
    PermissionStatus cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.undetermined &&
        microphonePermissionStatus == PermissionStatus.undetermined) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  static void _handleInvalidPermissions2(
    PermissionStatus contactPermissionStatus,
  ) {
    if (contactPermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to contact denied",
          details: null);
    } else if (contactPermissionStatus == PermissionStatus.undetermined) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
}
