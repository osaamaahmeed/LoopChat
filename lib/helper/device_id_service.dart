import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class DeviceIdService {
  static Future<String?> getDeviceId () async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String? deviceId;
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
        deviceId = info.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo info = await deviceInfoPlugin.iosInfo;
        deviceId = info.identifierForVendor;
      }
    } on PlatformException {
      print("Failed to get Device ID.");
      return null;
    }
    return deviceId;
  }
}