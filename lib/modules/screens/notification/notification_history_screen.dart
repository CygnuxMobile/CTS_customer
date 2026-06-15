import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/configs/app_text_style.dart';
import 'package:cts_customer/configs/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../notification_detail/notification_detail_screen.dart';
import '../../controllers/notification/notification_history_controller.dart';
import '../../models/notification/notification_model.dart';
import '../../widgets/flutter_toast.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationHistoryController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onLongPress: () async {
            try {
              String? token = await FirebaseMessaging.instance.getToken();
              if (token != null) {
                await Clipboard.setData(ClipboardData(text: token));
                toastMessage(text: "FCM Token Copied!", color: Colors.green);
                debugPrint("FCM Token: $token");
              }
            } catch (e) {
              toastMessage(text: "Error getting token", color: Colors.red);
            }
          },
          child: Text(
            "Notifications",
            style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (controller.notifications.isEmpty) {
                toastMessage(text: "No notifications to clear", color: AppColors.greyColor);
                return;
              }
              Get.dialog(
                AlertDialog(
                  title: const Text("Clear All"),
                  content: const Text("Are you sure you want to clear all notifications?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearAll();
                        Get.back();
                      },
                      child: Text("Yes", style: TextStyle(color: AppColors.primaryColor)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 26),
            tooltip: 'Clear All',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_outlined, size: 80, color: AppColors.greyColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  "No notifications yet!",
                  style: AppTextStyle.regular.copyWith(color: AppColors.greyColor, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return NotificationItem(
              notification: notification,
              onTap: () {
                // Mark as read and navigate to details
                controller.markAsRead(notification.id!);
                Get.to(
                  () => const NotificationDetailScreen(),
                  arguments: {
                    'title': notification.title,
                    'message': notification.body,
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: notification.isRead ? AppColors.borderColor : AppColors.primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: notification.isRead ? AppColors.greyColor.withOpacity(0.2) : AppColors.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppImages.logo,
                      height: 44,
                      width: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyle.bold.copyWith(
                                fontSize: 16,
                                color: notification.isRead ? Colors.black87 : AppColors.primaryColor,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDate(notification.time),
                        style: AppTextStyle.common(
                          fontSize: 12,
                          fontColor: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return isoString;
    }
  }
}
