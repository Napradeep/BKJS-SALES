import 'dart:developer';
import 'dart:io';

import 'package:bkjs_sales/src/utils/dio/dio.dart';
import 'package:bkjs_sales/src/utils/messenger/messenger.dart';
import 'package:bkjs_sales/src/utils/router/router.dart';
import 'package:bkjs_sales/src/view/homescreen.dart';
import 'package:bkjs_sales/src/view/registration.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationProvider extends ChangeNotifier {
  final TextEditingController usernameCTRL = TextEditingController();
  final TextEditingController regNoCTRL = TextEditingController();
  final _apiClient = NetworkUtils();
  String deviceId = '';
  String deviceName = '';

  /// Check if the user is already registered
  Future<void> checkRegistration(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? staffId = prefs.getInt('staff_id');

    if (staffId != null && staffId > 0) {
      /// User is already registered, go to HomeScreen
      MyRouter.pushRemoveUntil(
        screen: const HomeScreen(url: 'https://sales.bhangarukalasam.com'),
      );
    } else {
      /// User is NOT registered, go to RegistrationScreen
      MyRouter.pushRemoveUntil(screen: const RegistrationScreen());
    }
  }

  /// Submit Registration*
  Future<void> submit(BuildContext context) async {
    String name = usernameCTRL.text.trim();
    String regID = regNoCTRL.text.trim();

    if (name.isEmpty || regID.isEmpty) {
      Messenger.alertError("Please fill in all fields");
      return;
    }

    /// Fetch device ID and name
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        deviceName = iosInfo.utsname.machine;
      }
    } catch (e) {
      Messenger.alertError("Failed to get device info");
      return;
    }

    /// API Payload
    final data = {
      "staff_id": int.parse(regID),
      "device_id": deviceId,
      "device_name": deviceName,
      "status": 1,
      "user_name": name,
    };

    try {
      final Response? response = await _apiClient.request(
        endpoint: "/register",
        method: HttpMethod.post,
        data: data,
      );

      if (response?.data["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('staff_id', int.parse(regID));

        /// Navigate to Home Screen
        MyRouter.pushRemoveUntil(
          screen: const HomeScreen(url: 'https://sales.bhangarukalasam.com'),
        );

        Messenger.alertSuccess("Registered Successfully");
      } else {
        Messenger.alertError(
          response?.data["message"] ?? "Registration failed!",
        );
      }
    } catch (e) {
      Messenger.alertError("Already Registered");
    }
  }

  Future<void> sendLocationUpdate({
    required double latitude,
    required double longitude,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? staffId = prefs.getInt('staff_id');
      String dateTime = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).format(DateTime.now());
      print(staffId);

      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        deviceName = iosInfo.utsname.machine;
      }
      print(deviceId);

      if (staffId == null) {
        print(staffId);
        log("User not registered, skipping location update");
        return;
      }
      print(deviceName);

      Response? response = await _apiClient.request(
        endpoint: "/storelocation",
        method: HttpMethod.post,
        data: {
          "staff_id": staffId,
          "latitude": latitude,
          "longitude": longitude,
          "date_time": dateTime,
          "device_id": deviceId,
          "device_name": deviceName,
        },
      );

      print(response?.data);
      if (response?.statusCode == 200 && response?.data['success'] == true) {
        log("Location updated successfully: ${response?.data}");
      } else {
        log("Failed to update location: ${response?.data}");
      }
    } catch (e) {
      log("Error sending location update: $e");
    }
  }
}
