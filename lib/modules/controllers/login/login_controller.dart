import 'dart:convert';

import 'package:cts_customer/configs/app_endpoint.dart';
import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:cts_customer/modules/Bindings/dashBoard_binding/dashBoard_binding.dart';
import 'package:cts_customer/modules/screens/dashBoard/dashBoard_screen.dart';
import 'package:cts_customer/utils/http_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  Rx<TextEditingController> userIdController = TextEditingController(text: "").obs;
  Rx<TextEditingController> passwordController = TextEditingController(text: "").obs;
  RxBool isShow = false.obs;
  RxBool isLoading = false.obs;
  RxString fcmToken = "".obs;

  @override
  void onInit() {
    super.onInit();
    getFcmToken();
  }

  Future<void> getFcmToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
      }
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }

  Future<void> login({bool isLoading = false, Map<String, dynamic>? body}) async {
    try {
      this.isLoading.value = true;

      if (body != null && fcmToken.value.isNotEmpty) {
        body['fcm_token'] = fcmToken.value;
      }

      http.Response response = await HttpHandler.postRequest(url: ApiEndPoint.login, body: body);

      var data = jsonDecode(response.body);

      if (data['statusCode'] == 200) {
        if (data['data']['emptype'] == "11") {
          Pref.setData(LocalStorageKey.isLogin, true);
          Pref.setData(LocalStorageKey.token, data['data']['token']);
          Pref.setData(LocalStorageKey.fullName, data['data']['name'] ?? '');
          Pref.setData(LocalStorageKey.userId, data['data']['userId'] ?? '');
          Get.offAll(() => DashboardScreen(), binding: DashBoardBinding());
        } else {
          Fluttertoast.showToast(
            msg: "This app is only for customers",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("error = $e");
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      this.isLoading.value = false;
    }
  }
}
