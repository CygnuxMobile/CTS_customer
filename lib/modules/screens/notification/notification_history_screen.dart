import 'package:cts_customer/configs/app_colors.dart';
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

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final NotificationHistoryController controller = Get.put(NotificationHistoryController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Search Bar (collapsible)
            Obx(() {
              if (!controller.isSearchOpen.value) return const SizedBox.shrink();
              return _buildSearchBar();
            }),

            // Filter Tabs Bar (All, Unread, Read)
            _buildFilterTabs(),

            // Notification List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE30613)),
                        SizedBox(height: 12),
                        Text(
                          "Loading notifications...",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final list = controller.filteredNotifications;

                if (list.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: const Color(0xFFE30613),
                  onRefresh: () async {
                    await controller.fetchNotifications();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final notification = list[index];
                      return Dismissible(
                        key: ValueKey(notification.id ?? index),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (notification.id == null) return false;
                          await controller.deleteNotification(notification.id!);
                          toastMessage(text: "Notification deleted", color: AppColors.greyColor);
                          return true;
                        },
                        child: NotificationItem(
                          notification: notification,
                          onTap: () {
                            if (notification.id != null && !notification.isRead) {
                              controller.markAsRead(notification.id!);
                            }
                            Get.to(
                              () => const NotificationDetailScreen(),
                              arguments: {
                                'id': notification.id,
                                'title': notification.title,
                                'message': notification.body,
                                'time': notification.time,
                                'isRead': notification.isRead,
                              },
                            );
                          },
                          onDelete: () {
                            controller.showDeleteDialog(notification);
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Curved Header
  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE30613), Color(0xFFB0050F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26E30613),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: topPadding + 10,
        left: 12,
        right: 12,
        bottom: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: GestureDetector(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() {
                        final unread = controller.unreadCount.value;
                        final total = controller.notifications.length;
                        return Text(
                          unread > 0
                              ? "$unread unread • $total total"
                              : total > 0
                                  ? "$total notifications • All caught up"
                                  : "Notification Center",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Search Toggle Action
              Obx(() => IconButton(
                    onPressed: () {
                      controller.isSearchOpen.value = !controller.isSearchOpen.value;
                      if (!controller.isSearchOpen.value) {
                        _searchController.clear();
                        controller.searchQuery.value = '';
                      }
                    },
                    icon: Icon(
                      controller.isSearchOpen.value ? Icons.search_off_rounded : Icons.search_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: 'Search',
                  )),

              // Mark All As Read
              Obx(() {
                if (controller.unreadCount.value == 0) return const SizedBox.shrink();
                return IconButton(
                  onPressed: () {
                    controller.markAllAsRead();
                    toastMessage(text: "All marked as read", color: Colors.green);
                  },
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 22),
                  tooltip: 'Mark all as read',
                );
              }),

              // Clear All Action
              IconButton(
                onPressed: () => _confirmClearAll(context),
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
                tooltip: 'Clear All',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Collapsible Search Bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => controller.searchQuery.value = val,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: const InputDecoration(
                hintText: "Search notifications, dockets...",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                controller.searchQuery.value = '';
              },
              child: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 18),
            ),
        ],
      ),
    );
  }

  // Quick Filter Tabs (All, Unread, Read)
  Widget _buildFilterTabs() {
    return Obx(() {
      final current = controller.selectedFilter.value;
      final totalCount = controller.allCount;
      final unreadCount = controller.unreadCount.value;
      final readCount = controller.readCount;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12, bottom: 6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(
                label: "All",
                count: totalCount,
                isSelected: current == NotificationFilter.all,
                onTap: () => controller.selectedFilter.value = NotificationFilter.all,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: "Unread",
                count: unreadCount,
                hasHighlight: unreadCount > 0,
                isSelected: current == NotificationFilter.unread,
                onTap: () => controller.selectedFilter.value = NotificationFilter.unread,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: "Read",
                count: readCount,
                isSelected: current == NotificationFilter.read,
                onTap: () => controller.selectedFilter.value = NotificationFilter.read,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE30613)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE30613)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE30613).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : (hasHighlight
                        ? const Color(0xFFE30613).withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (hasHighlight ? const Color(0xFFE30613) : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Empty State
  Widget _buildEmptyState() {
    final isFiltered = controller.selectedFilter.value != NotificationFilter.all ||
        controller.searchQuery.value.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE30613).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isFiltered ? Icons.filter_alt_off_rounded : Icons.notifications_off_outlined,
                  size: 44,
                  color: const Color(0xFFE30613),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isFiltered ? "No Matching Notifications" : "No Notifications Yet!",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? "Try adjusting your search query or switching the filter tab."
                  : "You are all caught up! Updates regarding your bookings, dockets, and deliveries will appear here.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  controller.selectedFilter.value = NotificationFilter.all;
                  controller.searchQuery.value = '';
                  _searchController.clear();
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("Reset Filters"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Clear All Confirmation Dialog
  void _confirmClearAll(BuildContext context) {
    if (controller.notifications.isEmpty) {
      toastMessage(text: "No notifications to clear", color: AppColors.greyColor);
      return;
    }

    Get.defaultDialog(
      title: "Clear Notifications",
      titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B)),
      middleText: "Are you sure you want to delete all notifications? This action cannot be undone.",
      middleTextStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4),
      textConfirm: "Yes, Clear All",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE30613),
      textCancel: "Cancel",
      cancelTextColor: const Color(0xFF475569),
      radius: 16,
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      onConfirm: () {
        Get.back();
        controller.clearAll();
        toastMessage(text: "All notifications cleared", color: Colors.green);
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final category = _getCategory(notification.title, notification.body);
    final docketNumber = _extractDocketNumber(notification.title, notification.body);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFFDFD) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? const Color(0xFFE30613).withValues(alpha: 0.28)
              : const Color(0xFFE2E8F0),
          width: isUnread ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? const Color(0xFFE30613).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left Accent Stripe for unread items
            if (isUnread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4.5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE30613),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),

            // Card Inner
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isUnread ? 16 : 14, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar / Category Icon
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isUnread
                                    ? const Color(0xFFE30613).withValues(alpha: 0.3)
                                    : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AppImages.logo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Positioned(
                              top: -1,
                              right: -1,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE30613),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Category Tag & Time
                            Row(
                              children: [
                                // Category Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: (category['color'] as Color).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category['icon'] as IconData,
                                        size: 11,
                                        color: category['color'] as Color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        category['label'] as String,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: category['color'] as Color,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // Time with icon
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatSmartDate(notification.time),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 7),

                            // Notification Title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                                      color: isUnread
                                          ? const Color(0xFFE30613)
                                          : const Color(0xFF1E293B),
                                      letterSpacing: 0.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE30613),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Body preview if available
                            if (notification.body.isNotEmpty && notification.body != notification.title) ...[
                              const SizedBox(height: 5),
                              Text(
                                notification.body,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            // Bottom Row: Docket Chip & Tap action hint
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (docketNumber != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_shipping_outlined,
                                          size: 13,
                                          color: Color(0xFF475569),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          docketNumber,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const Spacer(),

                                // View Details Hint
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "View Details",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isUnread ? const Color(0xFFE30613) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: isUnread ? const Color(0xFFE30613) : const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detect category based on notification content
  Map<String, dynamic> _getCategory(String title, String body) {
    final text = '${title.toLowerCase()} ${body.toLowerCase()}';
    if (text.contains('deliver')) {
      return {
        'label': 'DELIVERY',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF059669),
      };
    } else if (text.contains('booking') || text.contains('booked')) {
      return {
        'label': 'BOOKING',
        'icon': Icons.confirmation_number_rounded,
        'color': const Color(0xFFE30613),
      };
    } else if (text.contains('transit') || text.contains('dispatch') || text.contains('pickup')) {
      return {
        'label': 'TRANSIT',
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFF2563EB),
      };
    } else if (text.contains('alert') || text.contains('delay') || text.contains('cancel') || text.contains('hold')) {
      return {
        'label': 'ALERT',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFD97706),
      };
    }
    return {
      'label': 'UPDATE',
      'icon': Icons.notifications_rounded,
      'color': const Color(0xFF64748B),
    };
  }

  // Extract possible docket / booking number for quick chip
  String? _extractDocketNumber(String title, String body) {
    final fullText = '$title $body';
    final regExp = RegExp(r'\b(CTS[-_]?[0-9A-Z]+|BK[-_]?[0-9A-Z]+|[0-9]{7,10})\b', caseSensitive: false);
    final match = regExp.firstMatch(fullText);
    return match?.group(0);
  }

  // Format date cleanly with relative timestamps
  String _formatSmartDate(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString);
      DateTime now = DateTime.now();
      Duration diff = now.difference(dt);

      if (diff.inSeconds < 60) {
        return "Just now";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24 && dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return "Today, ${DateFormat('hh:mm a').format(dt)}";
      } else if (dt.year == now.year && dt.month == now.month && dt.day == now.subtract(const Duration(days: 1)).day) {
        return "Yesterday, ${DateFormat('hh:mm a').format(dt)}";
      } else {
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      }
    } catch (e) {
      return isoString;
    }
  }
}
