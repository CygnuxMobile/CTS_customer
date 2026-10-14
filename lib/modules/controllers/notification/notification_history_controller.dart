import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/local/db_helper.dart';
import '../../models/notification/notification_model.dart';

enum NotificationFilter { all, unread, read }

class NotificationHistoryController extends GetxController {
  final DbHelper _dbHelper = DbHelper();
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var unreadCount = 0.obs;

  var selectedFilter = NotificationFilter.all.obs;
  var searchQuery = ''.obs;
  var isSearchOpen = false.obs;

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

  List<NotificationModel> get filteredNotifications {
    var list = notifications.toList();
    if (selectedFilter.value == NotificationFilter.unread) {
      list = list.where((n) => !n.isRead).toList();
    } else if (selectedFilter.value == NotificationFilter.read) {
      list = list.where((n) => n.isRead).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.body.toLowerCase().contains(query);
      }).toList();
    }
    return list;
  }

  int get allCount => notifications.length;
  int get readCount => notifications.where((n) => n.isRead).length;

  Future<void> markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
    await fetchNotifications();
  }

  Future<void> markAllAsRead() async {
    await _dbHelper.markAllAsRead();
    await fetchNotifications();
  }

  Future<void> deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
    await fetchNotifications();
  }

  Future<void> clearAll() async {
    await _dbHelper.clearAllNotifications();
    await fetchNotifications();
  }

  void showDeleteDialog(NotificationModel notification) {
    Get.defaultDialog(
      title: "Delete Notification",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B)),
      middleText: "Are you sure you want to delete this notification?",
      middleTextStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE30613),
      textCancel: "Cancel",
      cancelTextColor: Colors.grey.shade700,
      radius: 16,
      onConfirm: () async {
        Get.back();
        if (notification.id != null) {
          await deleteNotification(notification.id!);
        }
      },
    );
  }
}
