import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/local/db_helper.dart';
import '../../models/notification/notification_model.dart';

class NotificationHistoryController extends GetxController {
  final DbHelper _dbHelper = DbHelper();
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      notifications.value = await _dbHelper.getNotifications();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
    fetchNotifications();
  }

  Future<void> deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
    fetchNotifications();
  }

  Future<void> clearAll() async {
    await _dbHelper.clearAllNotifications();
    fetchNotifications();
  }

  void showDeleteDialog(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text("Do you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () {
              markAsRead(notification.id!);
              Get.back();
            },
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () async {
              await deleteNotification(notification.id!);
              Get.back();
            },
            child: const Text("YES", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
