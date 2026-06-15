import 'package:cts_customer/configs/app_images.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () async {
            debugPrint("Long press detected on Splash Logo");
            try {
              String? token = await FirebaseMessaging.instance.getToken();
              if (token != null) {
                await Clipboard.setData(ClipboardData(text: token));
                toastMessage(text: "FCM Token Copied!", color: Colors.green);
                debugPrint("FCM Token: $token");
              } else {
                toastMessage(text: "Could not get FCM Token", color: Colors.red);
              }
            } catch (e) {
              debugPrint("FCM Token Error: $e");
              toastMessage(text: "Error: $e", color: Colors.red);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              AppImages.logo,
              height: MediaQuery.of(context).size.width / 2.5,
              width: MediaQuery.of(context).size.width / 2.5,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
