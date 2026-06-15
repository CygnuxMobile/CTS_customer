import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:cts_customer/modules/Bindings/dashBoard_binding/dashBoard_binding.dart';
import 'package:cts_customer/modules/Bindings/login/login_binding.dart';
import 'package:cts_customer/modules/screens/dashBoard/dashBoard_screen.dart';
import 'package:cts_customer/modules/screens/login/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    getFcmToken();
    Future.delayed(const Duration(seconds: 3), () {
      final bool login = Pref.getData(LocalStorageKey.isLogin) ?? false;
      final String token = Pref.getData(LocalStorageKey.token) ?? "";

      if (login == true && token != "") {
        Get.offAll(() => DashboardScreen(), binding: DashBoardBinding());
      } else {
        Pref.clearData();
        Get.offAll(() => LoginScreen(), binding: LoginBinding());
      }
    });
  }

  Future<void> getFcmToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        Pref.setData(LocalStorageKey.fcmToken, token);
        debugPrint("FCM Token: $token");
      }
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }
}
