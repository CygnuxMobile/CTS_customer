import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/configs/app_images.dart';
import 'package:cts_customer/modules/controllers/docket_tracking/docket_tracking_controller.dart';
import 'package:cts_customer/modules/controllers/notification/notification_history_controller.dart';
import 'package:cts_customer/modules/screens/docket_tracking/docket_tracking_screen.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const NotificationDetailScreen({super.key, this.arguments});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isRawMessageExpanded = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = widget.arguments ??
        (Get.arguments is Map<String, dynamic> ? Get.arguments as Map<String, dynamic> : {});
    final id = args['id'];
    final int? notificationId = id is int ? id : int.tryParse(id?.toString() ?? '');
    final String title = args['title']?.toString() ?? 'Notification';
    final String message = args['message']?.toString() ?? args['body']?.toString() ?? 'No details available';
    final String time = args['time']?.toString() ?? '';
    final bool isRead = args['isRead'] == true || args['isRead'] == 1;

    final category = _getCategory(title, message);
    final parsed = _ParsedNotification.parse(message);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Modern Header
            _buildHeader(context, notificationId),

            // Detail Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Hero Card
                    _buildHeroCard(
                      title: title,
                      time: time,
                      isRead: isRead,
                      category: category,
                      parsed: parsed,
                    ),

                    const SizedBox(height: 12),

                    // Structured Consignment Card (if logistics data exists)
                    if (parsed.hasLogisticsData) ...[
                      _buildConsignmentCard(parsed),
                      const SizedBox(height: 12),
                    ],

                    // Original Message Card (collapsible / rich)
                    _buildMessageCard(title: title, message: message, parsed: parsed),

                    // Trust / Thank You Banner (if present)
                    if (parsed.footerNote != null && parsed.footerNote!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildFooterTrustBanner(parsed.footerNote!),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Curved Header
  Widget _buildHeader(BuildContext context, int? notificationId) {
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
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26E30613),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 12,
        right: 12,
        bottom: 14,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Notification Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          if (notificationId != null)
            IconButton(
              onPressed: () {
                Get.defaultDialog(
                  title: "Delete Notification",
                  titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1E293B)),
                  middleText: "Delete this notification permanently?",
                  middleTextStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  textConfirm: "Delete",
                  confirmTextColor: Colors.white,
                  buttonColor: const Color(0xFFE30613),
                  textCancel: "Cancel",
                  cancelTextColor: const Color(0xFF475569),
                  radius: 16,
                  onConfirm: () async {
                    Get.back();
                    if (Get.isRegistered<NotificationHistoryController>()) {
                      await Get.find<NotificationHistoryController>().deleteNotification(notificationId);
                    }
                    Get.back();
                    toastMessage(text: "Notification deleted", color: AppColors.greyColor);
                  },
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
              tooltip: "",
            ),
        ],
      ),
    );
  }

  // Summary Hero Card
  Widget _buildHeroCard({
    required String title,
    required String time,
    required bool isRead,
    required Map<String, dynamic> category,
    required _ParsedNotification parsed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo Avatar
              Container(
                height: 48,
                width: 48,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(AppImages.logo, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (category['color'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'] as IconData,
                                    size: 12,
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFFE30613).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isRead ? "Read" : "New",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isRead ? const Color(0xFF64748B) : const Color(0xFFE30613),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sub Message (if present)
          if (parsed.subMessage != null && parsed.subMessage!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF2563EB)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      parsed.subMessage!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Timestamp row
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatFullDate(time),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Structured Consignment / Logistics Card
  Widget _buildConsignmentCard(_ParsedNotification parsed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with LR No Badge & Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LR / Docket Badge
              if (parsed.lrNo != null)
                Flexible(
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: parsed.lrNo!));
                      toastMessage(text: "LR No. copied: ${parsed.lrNo}", color: AppColors.primaryColor);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt_long_rounded, size: 15, color: Color(0xFFE30613)),
                            const SizedBox(width: 5),
                            Text(
                              "LR: ${parsed.lrNo}",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF991B1B),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.copy_rounded, size: 13, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFFE30613)),
                        SizedBox(width: 6),
                        Text(
                          "CONSIGNMENT DETAILS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),

              // Booking Badge
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF15803D)),
                        SizedBox(width: 4),
                        Text(
                          "Confirmed",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Visual Route Section (From ──🚚──> To)
          if (parsed.fromLoc != null && parsed.toLoc != null) ...[
            const SizedBox(height: 12),
            _buildRouteSection(origin: parsed.fromLoc!, destination: parsed.toLoc!),
          ],

          // Parties Involved (Sender / Receiver)
          if (parsed.consignor != null || parsed.consignee != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  if (parsed.consignor != null)
                    Row(
                      children: [
                        Icon(Icons.business_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          "Sender: ",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Text(
                            parsed.consignor!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (parsed.consignor != null && parsed.consignee != null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),
                  if (parsed.consignee != null)
                    Row(
                      children: [
                        Icon(Icons.person_pin_circle_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          "Receiver: ",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Text(
                            parsed.consignee!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          // Key Metrics Bar (Qty, Weight, Date)
          if (parsed.qty != null || parsed.weight != null || parsed.date != null) ...[
            const SizedBox(height: 10),
            _buildMetricsBar(parsed),
          ],

          // Track Consignment Action Button
          if (parsed.lrNo != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE30613), Color(0xFFB0050F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE30613).withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(() => const DocketTrackingScreen());
                    if (Get.isRegistered<DocketTrackingController>()) {
                      Get.find<DocketTrackingController>().searchQuery.value = parsed.lrNo!;
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Track Consignment",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Visual Route Section (From ──🚚──> To)
  Widget _buildRouteSection({required String origin, required String destination}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Origin
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "FROM",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  origin,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Route Indicator Line with Truck
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 1.5, width: 12, color: Colors.grey.shade300),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 13,
                        color: Color(0xFFE30613),
                      ),
                    ),
                    Container(height: 1.5, width: 12, color: Colors.grey.shade300),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFFE30613),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Destination
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "TO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: Color(0xFFE30613),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  destination,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Key Metrics Bar (Qty, Weight, Date)
  Widget _buildMetricsBar(_ParsedNotification parsed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (parsed.qty != null) ...[
            Expanded(
              child: _buildMetricItem(
                icon: Icons.inventory_2_outlined,
                label: "Quantity",
                value: parsed.formattedQty,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(height: 22, width: 1, color: Colors.grey.shade300),
            ),
          ],
          if (parsed.weight != null) ...[
            Expanded(
              child: _buildMetricItem(
                icon: Icons.scale_outlined,
                label: "Weight",
                value: parsed.formattedWeight,
              ),
            ),
            if (parsed.date != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(height: 22, width: 1, color: Colors.grey.shade300),
              ),
          ],
          if (parsed.date != null)
            Expanded(
              child: _buildMetricItem(
                icon: Icons.calendar_month_outlined,
                label: "Booked On",
                value: parsed.date!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFFE30613)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Original Message Card (collapsible / rich)
  Widget _buildMessageCard({
    required String title,
    required String message,
    required _ParsedNotification parsed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.notes_rounded, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 6),
                        Text(
                          "ORIGINAL MESSAGE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "$title\n\n$message"));
                    toastMessage(text: "Message copied to clipboard", color: Colors.green);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 13, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          "Copy",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Padding(
            padding: const EdgeInsets.all(16),
            child: parsed.hasLogisticsData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        _isRawMessageExpanded ? message : _cleanPreview(message),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF475569),
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isRawMessageExpanded = !_isRawMessageExpanded;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isRawMessageExpanded ? "Show Less" : "View Full Text",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE30613),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              _isRawMessageExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: const Color(0xFFE30613),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SelectableText(
                    message,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF334155),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Footer Trust Banner
  Widget _buildFooterTrustBanner(String footerNote) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              footerNote,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _cleanPreview(String raw) {
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length <= 4) return raw;
    return "${lines.take(3).join('\n')}\n...";
  }

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

  String _formatFullDate(String isoString) {
    if (isoString.isEmpty) {
      final now = DateTime.now();
      return DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(now);
    }
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(dt);
    } catch (e) {
      return isoString;
    }
  }
}

// Intelligent Parser for Logistics Notification Messages
class _ParsedNotification {
  final String? lrNo;
  final String? date;
  final String? qty;
  final String? weight;
  final String? fromLoc;
  final String? toLoc;
  final String? consignor;
  final String? consignee;
  final String? subMessage;
  final String? footerNote;
  final bool hasLogisticsData;

  const _ParsedNotification({
    this.lrNo,
    this.date,
    this.qty,
    this.weight,
    this.fromLoc,
    this.toLoc,
    this.consignor,
    this.consignee,
    this.subMessage,
    this.footerNote,
    this.hasLogisticsData = false,
  });

  String get formattedQty {
    if (qty == null) return "-";
    final clean = qty!.trim();
    if (clean.toLowerCase().contains("pkg") || clean.toLowerCase().contains("box") || clean.toLowerCase().contains("bag")) {
      return clean;
    }
    final numVal = num.tryParse(clean);
    if (numVal != null) {
      return numVal % 1 == 0 ? "${numVal.toInt()} Pkgs" : "$numVal Pkgs";
    }
    return "$clean Pkgs";
  }

  String get formattedWeight {
    if (weight == null) return "-";
    final clean = weight!.trim();
    if (clean.toLowerCase().contains("kg") || clean.toLowerCase().contains("ton") || clean.toLowerCase().contains("qtl")) {
      return clean;
    }
    final numVal = num.tryParse(clean);
    if (numVal != null) {
      return numVal % 1 == 0 ? "${numVal.toInt()} Kg" : "$numVal Kg";
    }
    return "$clean Kg";
  }

  factory _ParsedNotification.parse(String message) {
    if (message.trim().isEmpty) return const _ParsedNotification();

    String? lrNo;
    String? date;
    String? qty;
    String? weight;
    String? fromLoc;
    String? toLoc;
    String? consignor;
    String? consignee;
    String? subMessage;
    String? footerNote;

    // LR No / Docket No
    final lrMatch = RegExp(
      r'(?:LR\s*No|Docket\s*No|CN\s*No|Doc\s*No|LR|Docket)\s*[:=-]?\s*([0-9A-Za-z]+)',
      caseSensitive: false,
    ).firstMatch(message);
    if (lrMatch != null) {
      lrNo = lrMatch.group(1)?.trim();
    } else {
      final standaloneMatch = RegExp(r'\b([0-9]{8,11})\b').firstMatch(message);
      if (standaloneMatch != null) {
        lrNo = standaloneMatch.group(1)?.trim();
      }
    }

    // Date
    final dateMatch = RegExp(
      r'(?:Date|Dt|Booking\s*Date)\s*[:=-]?\s*([0-9]{1,2}\s+[A-Za-z]{3,}\s+[0-9]{4}|[0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})',
      caseSensitive: false,
    ).firstMatch(message);
    if (dateMatch != null) {
      date = dateMatch.group(1)?.trim();
    }

    // Qty
    final qtyMatch = RegExp(
      r'(?:Qty|Quantity|Packages|Pkgs)\s*[:=-]?\s*([0-9]+(?:\.[0-9]+)?(?:\s*[A-Za-z]+)?)',
      caseSensitive: false,
    ).firstMatch(message);
    if (qtyMatch != null) {
      qty = qtyMatch.group(1)?.trim();
    }

    // Weight
    final wtMatch = RegExp(
      r'(?:Weight|Wt|Act\s*Wt)\s*[:=-]?\s*([0-9]+(?:\.[0-9]+)?(?:\s*[A-Za-z]+)?)',
      caseSensitive: false,
    ).firstMatch(message);
    if (wtMatch != null) {
      weight = wtMatch.group(1)?.trim();
    }

    // From (Origin) - e.g. "From: DAPODA BWD"
    final fromMatch = RegExp(
      r'(?:^|\n)\s*From\s*:\s*([^\n\r]+)',
      caseSensitive: false,
    ).firstMatch(message);
    if (fromMatch != null) {
      fromLoc = fromMatch.group(1)?.trim();
    }

    // To (Destination) - e.g. "To: PUNE CITY"
    final toMatch = RegExp(
      r'(?:^|\n)\s*To\s*:\s*([^\n\r]+)',
      caseSensitive: false,
    ).firstMatch(message);
    if (toMatch != null) {
      toLoc = toMatch.group(1)?.trim();
    }

    // Sender / Consignor - e.g. "From,R J ENTERPRISE" or "Consignor: ..."
    final consignorMatch = RegExp(
      r'(?:From\s*,\s*|Consignor\s*[:=-]\s*)([^\n\r]+)',
      caseSensitive: false,
    ).firstMatch(message);
    if (consignorMatch != null) {
      consignor = consignorMatch.group(1)?.trim();
    }

    // Receiver / Consignee - e.g. "Dear ARYA DECOR" or "Consignee: ..."
    final consigneeMatch = RegExp(
      r'(?:Dear\s+|Consignee\s*[:=-]\s*)([^\n\r,]+)',
      caseSensitive: false,
    ).firstMatch(message);
    if (consigneeMatch != null) {
      consignee = consigneeMatch.group(1)?.trim();
    }

    // Sub Message - e.g. "Your transport booking has been successfully received."
    final subMsgMatch = RegExp(
      r'([^\n\r]*(?:booking|delivery|dispatch|received|scheduled|arrived)[^\n\r]*)',
      caseSensitive: false,
    ).firstMatch(message);
    if (subMsgMatch != null) {
      final text = subMsgMatch.group(1)?.trim();
      if (text != null &&
          !text.toLowerCase().contains('chintamani') &&
          !text.toLowerCase().contains('confirmed!') &&
          !text.toLowerCase().contains('lr no')) {
        subMessage = text;
      }
    }

    // Footer note - e.g. "Thank you for trusting us!"
    final footerMatch = RegExp(
      r'(Thank\s+you[^\n\r]*)',
      caseSensitive: false,
    ).firstMatch(message);
    if (footerMatch != null) {
      footerNote = footerMatch.group(1)?.trim();
    }

    final hasLogistics = (lrNo != null) || (fromLoc != null && toLoc != null) || qty != null || weight != null;

    return _ParsedNotification(
      lrNo: lrNo,
      date: date,
      qty: qty,
      weight: weight,
      fromLoc: fromLoc,
      toLoc: toLoc,
      consignor: consignor,
      consignee: consignee,
      subMessage: subMessage,
      footerNote: footerNote,
      hasLogisticsData: hasLogistics,
    );
  }
}
