import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:switchcalls/models/message.dart';

class LocationUtils {
  static final Geolocator geolocator = Geolocator()
    ..forceAndroidLocationManager;

  static Future<MyLocation> getCurrentLocation() async {
    try {
      await Permission.locationAlways.request();
      PermissionStatus status = await Permission.location.status;
      // print('STATUS IS $status');
      if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
        return null;
      } else if (status == PermissionStatus.denied) {
        return null;
      }
      Position position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      if (position != null) {
        return await _getAddressFromLatLng(position);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<MyLocation> _getAddressFromLatLng(
      Position _currentPosition) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      // Placemark place = p[0];
      return MyLocation(
        lat: _currentPosition.latitude,
        long: _currentPosition.longitude,
      );
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
