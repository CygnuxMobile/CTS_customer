import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/modules/controllers/dashBoard/dashBoard_controller.dart';
import 'package:cts_customer/modules/controllers/docket_tracking/docket_tracking_controller.dart';
import 'package:cts_customer/modules/models/dashBoard/location.dart';
import 'package:cts_customer/modules/models/docket_tracking/docket_tracking_model.dart';
import 'package:cts_customer/modules/screens/Pod_view_screen/pod_view_screen.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DocketTrackingScreen extends StatefulWidget {
  final String? locCode;

  const DocketTrackingScreen({super.key, this.locCode});

  @override
  State<DocketTrackingScreen> createState() => _DocketTrackingScreenState();
}

class _DocketTrackingScreenState extends State<DocketTrackingScreen> {
  late final DocketTrackingController docketTrackingController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    docketTrackingController = Get.isRegistered<DocketTrackingController>()
        ? Get.find<DocketTrackingController>()
        : Get.put(DocketTrackingController());

    docketTrackingController.docketTrackingApi(
      locCode: widget.locCode,
      fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
      toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Modern Notification-style Curved Header
            _buildHeader(context),

            // Top Search & Summary Bar
            _buildSearchAndFilterHeader(),

          // Main List View
          Expanded(
            child: Obx(() {
              if (docketTrackingController.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFE30613)),
                      SizedBox(height: 12),
                      Text("Loading consignments...", style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                );
              }

              if (docketTrackingController.errorMessage.isNotEmpty && docketTrackingController.docketList.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 54, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(
                          docketTrackingController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            docketTrackingController.resetFilters(defaultLocCode: widget.locCode);
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Reset Filters"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE30613),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final list = docketTrackingController.filteredDocketList;

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping_outlined, size: 48, color: Color(0xFFE30613)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Dockets Found",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          docketTrackingController.searchQuery.value.isNotEmpty
                              ? "No results matching \"${docketTrackingController.searchQuery.value}\""
                              : "No records found for the selected filter.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        if (docketTrackingController.isFilterApplied.value || docketTrackingController.searchQuery.value.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              docketTrackingController.resetFilters(defaultLocCode: widget.locCode);
                            },
                            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE30613)),
                            label: const Text("Reset All Filters", style: TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFFE30613),
                onRefresh: () async {
                  await docketTrackingController.docketTrackingApi(
                    locCode: docketTrackingController.appliedLocCode.value.isNotEmpty
                        ? docketTrackingController.appliedLocCode.value
                        : widget.locCode,
                    fromDate: docketTrackingController.appliedFromDate.value != null
                        ? DateFormat("dd MMM yyyy").format(docketTrackingController.appliedFromDate.value!)
                        : DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
                    toDate: docketTrackingController.appliedToDate.value != null
                        ? DateFormat("dd MMM yyyy").format(docketTrackingController.appliedToDate.value!)
                        : DateFormat("dd MMM yyyy").format(DateTime.now()),
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 90, left: 12, right: 12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildDocketCard(item);
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

  // Modern Curved Header (Notification Style)
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
        left: 14,
        right: 14,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Docket Tracking",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final total = docketTrackingController.docketList.length;
                  final isFiltered = docketTrackingController.isFilterApplied.value;
                  return Text(
                    isFiltered
                        ? "Filters Active • $total Dockets"
                        : total > 0
                            ? "$total Dockets Available"
                            : "Live Consignment Tracking",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Filter Button
          Obx(() {
            final isFiltered = docketTrackingController.isFilterApplied.value;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFilterBottomSheet(context),
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (isFiltered)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.amberAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE30613), width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Header Search & Active Filter Chips
  Widget _buildSearchAndFilterHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.all(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search TextField
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) {
                docketTrackingController.searchQuery.value = val;
              },
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Search Docket No, City, Consignor...",
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 44,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 44,
                ),
                suffixIcon: Obx(() {
                  if (docketTrackingController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchController.clear();
                        docketTrackingController.searchQuery.value = "";
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Count and Active Filter Tag
          const SizedBox(height: 8),
          Obx(() {
            final total = docketTrackingController.docketList.length;
            final filtered = docketTrackingController.filteredDocketList.length;
            final isFiltered = docketTrackingController.isFilterApplied.value;

            return Row(
              children: [
                Expanded(
                  child: Text(
                    docketTrackingController.searchQuery.value.isNotEmpty
                        ? "Showing $filtered of $total Dockets"
                        : "$total Dockets Found",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isFiltered) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      docketTrackingController.resetFilters(defaultLocCode: widget.locCode);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_alt_off_rounded, size: 13, color: Color(0xFFE30613)),
                          SizedBox(width: 4),
                          Text(
                            "Clear Filter",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE30613),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  // Modern Docket Card
  Widget _buildDocketCard(DocketList item) {
    final statusConfig = _StatusConfig.fromStatus(item.oPStatus);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Docket No with Copy button + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Docket No Badge with Copy
                Flexible(
                  flex: 3,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: item.dockno));
                      toastMessage(text: "Docket No. copied: ${item.dockno}", color: AppColors.primaryColor);
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
                              item.dockno,
                              style: const TextStyle(
                                fontSize: 14,
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
                ),
                const SizedBox(width: 8),

                // Status Badge
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusConfig.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusConfig.borderColor),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusConfig.icon, size: 14, color: statusConfig.textColor),
                          const SizedBox(width: 5),
                          Text(
                            statusConfig.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusConfig.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Route Section (From ──🚚──> To)
            _buildRouteSection(item),

            const SizedBox(height: 10),

            // Consignor Row
            if (item.csgnnm.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business_rounded, size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      "Consignor: ",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        item.csgnnm,
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
              ),
              const SizedBox(height: 10),
            ],

            // Dates Timeline Row
            _buildDatesSection(item),

            const SizedBox(height: 10),

            // Key Metrics Bar (Packages, Weight, Amount)
            _buildMetricsBar(item),

            // Operational Status Details (if present)
            if (item.oPStatus.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildStatusNote(item),
            ],

            const SizedBox(height: 12),

            // POD Document Action Button
            _buildPodButton(item),
          ],
        ),
      ),
    );
  }

  // Visual Route Section (From ──🚚──> To) - Box 1
  Widget _buildRouteSection(DocketList item) {
    final origin = (item.froMLoc.isNotEmpty ? item.froMLoc : (item.orgncd.isNotEmpty ? item.orgncd : "-")).trim();
    final destination = (item.tOLoc.isNotEmpty ? item.tOLoc : (item.destcd.isNotEmpty ? item.destcd : "-")).trim();

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(height: 1.5, color: Colors.grey.shade300),
                  ),
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
                  Expanded(
                    child: Container(height: 1.5, color: Colors.grey.shade300),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: Color(0xFFE30613),
                  ),
                ],
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

  // Lifecycle Dates Row (Booked, Expected, Delivered) - Box 2
  Widget _buildDatesSection(DocketList item) {
    final isDelivered = item.oPStatus.toLowerCase().contains('deliver');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Booking Date
          Expanded(
            child: _buildDateItem(
              icon: Icons.calendar_month_outlined,
              label: "Booked",
              value: item.dockdt.isNotEmpty ? item.dockdt : "-",
              iconColor: Colors.grey.shade700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade300,
            ),
          ),
          // Expected Delivery Date
          Expanded(
            child: _buildDateItem(
              icon: Icons.schedule_rounded,
              label: "Expected",
              value: item.edd.isNotEmpty ? item.edd : "-",
              iconColor: const Color(0xFF2563EB),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade300,
            ),
          ),
          // Actual Delivery Date
          Expanded(
            child: _buildDateItem(
              icon: Icons.task_alt_rounded,
              label: "Delivered",
              value: item.add.isNotEmpty ? item.add : "-",
              iconColor: isDelivered ? const Color(0xFF16A34A) : Colors.grey.shade700,
              valueColor: isDelivered ? const Color(0xFF15803D) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: iconColor),
            const SizedBox(width: 3),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // Key Metrics Bar: Qty, Weight, Amount - Box 3
  Widget _buildMetricsBar(DocketList item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Packages / Qty
          Expanded(
            child: _buildMetricItem(
              icon: Icons.inventory_2_outlined,
              label: "Qty",
              value: "${_formatQty(item.pkgsno)} Pkgs",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(height: 22, width: 1, color: Colors.grey.shade300),
          ),
          // Weight
          Expanded(
            child: _buildMetricItem(
              icon: Icons.scale_outlined,
              label: "Weight",
              value: _formatWeight(item.actuwt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(height: 22, width: 1, color: Colors.grey.shade300),
          ),
          // Amount
          Expanded(
            child: _buildMetricItem(
              icon: Icons.currency_rupee_rounded,
              label: "Amount",
              value: _formatAmount(item.dkttot),
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

  // Detailed Operational Status Note
  Widget _buildStatusNote(DocketList item) {
    final isDelivered = item.oPStatus.toLowerCase().contains('deliver');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDelivered ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDelivered ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDelivered ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 15,
            color: isDelivered ? const Color(0xFF16A34A) : Colors.blueGrey,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              item.oPStatus,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDelivered ? const Color(0xFF166534) : const Color(0xFF334155),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // POD Document Action Button
  Widget _buildPodButton(DocketList item) {
    final hasPod = item.podlink != null && item.podlink.toString().trim().isNotEmpty;

    if (hasPod) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
              () => PodViewScreen(
                podImage: "http://cts.cygnux.in/Images/FMScanDocument/${item.podlink}",
                fileName: item.dockno,
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
            ),
            child: const Row(
              children: [
                Icon(Icons.description_outlined, size: 16, color: Color(0xFFE30613)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "View POD Document",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE30613),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFFE30613)),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_off_outlined, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "POD not uploaded yet",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Modern Filter Bottom Sheet
  void _showFilterBottomSheet(BuildContext context) {
    final DashboardController dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header: Clear | Title | Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          docketTrackingController.resetFilters(defaultLocCode: widget.locCode);
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: const Text(
                          "Reset",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFE30613)),
                        ),
                      ),
                      const Text(
                        "Filter Dockets",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // Location Selector
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return DropdownSearch<LocationList>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search Location",
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      items: dashboardController.location,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Select Location",
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFE30613), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE30613), width: 1.5),
                          ),
                        ),
                      ),
                      itemAsString: (v) => "${v.locName}",
                      selectedItem: docketTrackingController.selectedLocation.value,
                      onChanged: (LocationList? value) {
                        docketTrackingController.selectedLocation.value = value;
                      },
                    );
                  }),

                  const SizedBox(height: 18),

                  // Quick Date Presets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Date Range",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          _buildPresetChip("7 Days", 7),
                          _buildPresetChip("15 Days", 15),
                          _buildPresetChip("30 Days", 30),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // From Date & To Date side-by-side Cards
                  Row(
                    children: [
                      // From Date
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final now = DateTime.now();
                            final initial = docketTrackingController.selectedFromDate.value ?? now.subtract(const Duration(days: 30));
                            final selected = await showDatePicker(
                              context: bottomSheetContext,
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2035),
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              initialDate: initial.isBefore(now) ? initial : now,
                            );
                            if (selected != null) {
                              docketTrackingController.selectedFromDate.value = selected;
                            }
                          },
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFE30613)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "From Date",
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                      ),
                                      Obx(() {
                                        final date = docketTrackingController.selectedFromDate.value;
                                        return Text(
                                          date != null ? DateFormat("dd MMM yyyy").format(date) : "Select Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: date != null ? const Color(0xFF0F172A) : Colors.grey.shade500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Obx(() {
                                  if (docketTrackingController.selectedFromDate.value != null) {
                                    return GestureDetector(
                                      onTap: () => docketTrackingController.selectedFromDate.value = null,
                                      child: const Icon(Icons.cancel_rounded, size: 16, color: Colors.grey),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // To Date
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final now = DateTime.now();
                            final initial = docketTrackingController.selectedToDate.value ?? now;
                            final selected = await showDatePicker(
                              context: bottomSheetContext,
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2035),
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              initialDate: initial.isBefore(now) ? initial : now,
                            );
                            if (selected != null) {
                              docketTrackingController.selectedToDate.value = selected;
                            }
                          },
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available_rounded, size: 16, color: Color(0xFFE30613)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "To Date",
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                      ),
                                      Obx(() {
                                        final date = docketTrackingController.selectedToDate.value;
                                        return Text(
                                          date != null ? DateFormat("dd MMM yyyy").format(date) : "Select Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: date != null ? const Color(0xFF0F172A) : Colors.grey.shade500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Obx(() {
                                  if (docketTrackingController.selectedToDate.value != null) {
                                    return GestureDetector(
                                      onTap: () => docketTrackingController.selectedToDate.value = null,
                                      child: const Icon(Icons.cancel_rounded, size: 16, color: Colors.grey),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Apply Filter Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE30613), Color(0xFFB0050F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE30613).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (docketTrackingController.selectedFromDate.value == null ||
                              docketTrackingController.selectedToDate.value == null) {
                            Get.snackbar(
                              'Filter Required',
                              'Please select From Date and To Date to filter records.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(12),
                              borderRadius: 10,
                            );
                            return;
                          }

                          docketTrackingController.docketTrackingApi(
                            locCode: docketTrackingController.selectedLocation.value?.locCode ?? widget.locCode,
                            fromDate: DateFormat("dd MMM yyyy").format(docketTrackingController.selectedFromDate.value!),
                            toDate: DateFormat("dd MMM yyyy").format(docketTrackingController.selectedToDate.value!),
                            isFromFilterTab: true,
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_alt_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Apply Filter",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Quick Preset Chip
  Widget _buildPresetChip(String title, int days) {
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        docketTrackingController.selectedFromDate.value = now.subtract(Duration(days: days));
        docketTrackingController.selectedToDate.value = now;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  // Formatting Helpers
  static String _formatQty(num? val) {
    if (val == null) return "0";
    return val % 1 == 0 ? "${val.toInt()}" : val.toString();
  }

  static String _formatWeight(num? val) {
    if (val == null) return "0 Kg";
    return val % 1 == 0 ? "${val.toInt()} Kg" : "$val Kg";
  }

  static String _formatAmount(num? val) {
    if (val == null) return "₹ 0";
    return "₹ ${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(2)}";
  }
}

// Helper Configuration for Status Badge
class _StatusConfig {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  factory _StatusConfig.fromStatus(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s.contains('deliver')) {
      return const _StatusConfig(
        label: "Delivered",
        icon: Icons.check_circle_rounded,
        textColor: Color(0xFF15803D),
        bgColor: Color(0xFFDCFCE7),
        borderColor: Color(0xFF86EFAC),
      );
    } else if (s.contains('out for delivery')) {
      return const _StatusConfig(
        label: "Out For Delivery",
        icon: Icons.delivery_dining_rounded,
        textColor: Color(0xFFB45309),
        bgColor: Color(0xFFFEF3C7),
        borderColor: Color(0xFFFDE68A),
      );
    } else if (s.contains('transit') || s.contains('dispatch') || s.contains('depart')) {
      return const _StatusConfig(
        label: "In Transit",
        icon: Icons.local_shipping_rounded,
        textColor: Color(0xFF1D4ED8),
        bgColor: Color(0xFFDBEAFE),
        borderColor: Color(0xFF93C5FD),
      );
    } else if (s.contains('cancel') || s.contains('reject')) {
      return const _StatusConfig(
        label: "Cancelled",
        icon: Icons.cancel_rounded,
        textColor: Color(0xFFB91C1C),
        bgColor: Color(0xFFFEE2E2),
        borderColor: Color(0xFFFCA5A5),
      );
    } else if (s.contains('book') || s.contains('pickup')) {
      return const _StatusConfig(
        label: "Booked",
        icon: Icons.bookmark_added_rounded,
        textColor: Color(0xFF6B21A8),
        bgColor: Color(0xFFF3E8FF),
        borderColor: Color(0xFFD8B4FE),
      );
    } else if (rawStatus.trim().isNotEmpty) {
      final words = rawStatus.trim().split(' ');
      final display = words.length > 2 ? "${words.take(2).join(' ')}..." : rawStatus.trim();
      return _StatusConfig(
        label: display,
        icon: Icons.info_outline_rounded,
        textColor: const Color(0xFF334155),
        bgColor: const Color(0xFFF1F5F9),
        borderColor: const Color(0xFFCBD5E1),
      );
    } else {
      return const _StatusConfig(
        label: "Pending",
        icon: Icons.hourglass_top_rounded,
        textColor: Color(0xFF475569),
        bgColor: Color(0xFFF8FAFC),
        borderColor: Color(0xFFE2E8F0),
      );
    }
  }
}
