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

    if (contactPermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions2(contactPermissionStatus);
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

  // static Future<PermissionStatus> _getCameraPermission() async {
  //   PermissionStatus permission =
  //       await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.disabled) {
  //     Map<PermissionGroup, PermissionStatus> permissionStatus =
  //         await PermissionHandler()
  //             .requestPermissions([PermissionGroup.camera]);
  //     return permissionStatus[PermissionGroup.camera] ??
  //         PermissionStatus.unknown;
  //   } else {
  //     return permission;
  //   }
  // }
  static Future<PermissionStatus> _getMicrophonePermission() async {
    bool permission = await Permission.microphone.isGranted;
    if (!permission) {
      await Permission.microphone.request();
    }
    return await Permission.microphone.status;
  }

  // static Future<PermissionStatus> _getMicrophonePermission() async {
  //   PermissionStatus permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.microphone);
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.disabled) {
  //     Map<PermissionGroup, PermissionStatus> permissionStatus =
  //         await PermissionHandler()
  //             .requestPermissions([PermissionGroup.microphone]);
  //     return permissionStatus[PermissionGroup.microphone] ??
  //         PermissionStatus.unknown;
  //   } else {
  //     return permission;
  //   }
  // }

  static Future<PermissionStatus> _getContactPermission() async {
    bool permission = await Permission.contacts.isGranted;
    if (!permission) {
      await Permission.contacts.request();
    }
    return await Permission.contacts.status;
  }

  // static Future<PermissionStatus> _getContactPermission() async {
  //   PermissionStatus permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.contacts);
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.disabled) {
  //     Map<PermissionGroup, PermissionStatus> permissionStatus =
  //         await PermissionHandler()
  //             .requestPermissions([PermissionGroup.contacts]);
  //     return permissionStatus[PermissionGroup.contacts] ??
  //         PermissionStatus.unknown;
  //   } else {
  //     return permission;
  //   }
  // }

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
