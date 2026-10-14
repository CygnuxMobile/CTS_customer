import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_colors.dart';
import '../../controllers/mis_report/mis_report_controller.dart';
import '../../models/mis_report/mis_report_model.dart';
import '../../widgets/flutter_toast.dart';

class MisReportScreen extends StatefulWidget {
  const MisReportScreen({super.key});

  @override
  State<MisReportScreen> createState() => _MisReportScreenState();
}

class _MisReportScreenState extends State<MisReportScreen> {
  late final MisReportController misReportController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _docketNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    misReportController = Get.isRegistered<MisReportController>()
        ? Get.find<MisReportController>()
        : Get.put(MisReportController());

    misReportController.misReportApi(
      fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
      toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
      dockno: "",
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _docketNoController.dispose();
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
                if (misReportController.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE30613)),
                        SizedBox(height: 12),
                        Text(
                          "Loading MIS reports...",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                if (misReportController.errorMessage.isNotEmpty && misReportController.docketLists.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 54, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text(
                            misReportController.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              _docketNoController.clear();
                              misReportController.resetFilters();
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

                final list = misReportController.filteredDocketList;

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
                            child: const Icon(Icons.assessment_outlined, size: 48, color: Color(0xFFE30613)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No Records Found",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            misReportController.searchQuery.value.isNotEmpty
                                ? "No results matching \"${misReportController.searchQuery.value}\""
                                : "No records found for the selected filter.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          if (misReportController.isFilterApplied.value || misReportController.searchQuery.value.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                _docketNoController.clear();
                                misReportController.resetFilters();
                              },
                              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE30613)),
                              label: const Text(
                                "Reset All Filters",
                                style: TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFE30613),
                  onRefresh: () async {
                    await misReportController.misReportApi(
                      fromDate: misReportController.appliedFromDate.value != null
                          ? DateFormat("dd MMM yyyy").format(misReportController.appliedFromDate.value!)
                          : DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
                      toDate: misReportController.appliedToDate.value != null
                          ? DateFormat("dd MMM yyyy").format(misReportController.appliedToDate.value!)
                          : DateFormat("dd MMM yyyy").format(DateTime.now()),
                      dockno: misReportController.appliedDockNo.value,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24, left: 12, right: 12),
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
                    "MIS Report",
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
                  final total = misReportController.docketLists.length;
                  final isFiltered = misReportController.isFilterApplied.value;
                  return Text(
                    isFiltered
                        ? "Filters Active • $total Records"
                        : total > 0
                            ? "$total Reports Found"
                            : "Management Information System",
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
            final isFiltered = misReportController.isFilterApplied.value;
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
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) {
                misReportController.searchQuery.value = val;
              },
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Search Docket, City, Consignor...",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 44,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minHeight: 44,
                ),
                suffixIcon: Obx(() {
                  if (misReportController.searchQuery.value.isNotEmpty) {
                    final filtered = misReportController.filteredDocketList.length;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$filtered found",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _searchController.clear();
                            misReportController.searchQuery.value = "";
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),

          // Active Filter Tag
          Obx(() {
            final isFiltered = misReportController.isFilterApplied.value;
            if (!isFiltered) return const SizedBox.shrink();

            String filterDetails = "";
            if (misReportController.appliedDockNo.value.isNotEmpty) {
              filterDetails = "Docket: ${misReportController.appliedDockNo.value}";
            } else if (misReportController.appliedFromDate.value != null && misReportController.appliedToDate.value != null) {
              filterDetails =
                  "${DateFormat('dd MMM').format(misReportController.appliedFromDate.value!)} - ${DateFormat('dd MMM').format(misReportController.appliedToDate.value!)}";
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune_rounded, size: 12, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 4),
                        Text(
                          filterDetails.isNotEmpty ? "Filter: $filterDetails" : "Filter Applied",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _docketNoController.clear();
                      misReportController.resetFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_alt_off_rounded, size: 12, color: Color(0xFFE30613)),
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
              ),
            );
          }),
        ],
      ),
    );
  }

  // Modern Docket Card
  Widget _buildDocketCard(DocketList item) {
    final statusConfig = _StatusConfig.fromStatus(item.status);

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
            // Top Row: Docket No with Copy button + Docket Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Docket No Badge with Copy
                InkWell(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFFE30613)),
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

                // Date
                if (item.docketDate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          item.docketDate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Status Banner / Pill
            if (item.status.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: statusConfig.bgColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusConfig.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(statusConfig.icon, size: 15, color: statusConfig.textColor),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        "Status: ${item.status}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusConfig.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Route Section (From ──🚚──> To)
            _buildRouteSection(item),

            const SizedBox(height: 10),

            // Consignor & Consignee Box
            _buildPartiesSection(item),

            // Dates Section (Expected EDD & Delivery Date)
            if (item.edd.trim().isNotEmpty || item.delivery.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDatesSection(item),
            ],

            const SizedBox(height: 10),

            // Key Metrics Bar (Packages, Actual Wt)
            _buildMetricsBar(item),
          ],
        ),
      ),
    );
  }

  // Visual Route Section (From ──🚚──> To)
  Widget _buildRouteSection(DocketList item) {
    final origin = item.fromCity.isNotEmpty ? item.fromCity.trim() : "-";
    final destination = item.toCity.isNotEmpty ? item.toCity.trim() : "-";

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
                  Expanded(child: Container(height: 1.5, color: Colors.grey.shade300)),
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
                  Expanded(child: Container(height: 1.5, color: Colors.grey.shade300)),
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

  // Parties Section (Consignor & Consignee)
  Widget _buildPartiesSection(DocketList item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consignor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.business_rounded, size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "CONSIGNOR",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.consignorName.isNotEmpty ? item.consignorName : "-",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 36,
              width: 1,
              color: Colors.grey.shade300,
            ),
          ),

          // Consignee
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storefront_rounded, size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "CONSIGNEE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.consigneeName.isNotEmpty ? item.consigneeName : "-",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
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

  // Dates Section: Expected (EDD) & Delivery Date
  Widget _buildDatesSection(DocketList item) {
    final bool hasEdd = item.edd.trim().isNotEmpty;
    final bool hasDelivery = item.delivery.trim().isNotEmpty;
    final bool isDelivered = item.status.toLowerCase().contains('deliver');

    if (!hasEdd && !hasDelivery) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Expected Delivery Date (EDD)
          Expanded(
            child: _buildMetricItem(
              icon: Icons.schedule_rounded,
              label: "Expected (EDD)",
              value: hasEdd ? item.edd : "-",
              iconColor: const Color(0xFF2563EB),
              valueColor: const Color(0xFF1D4ED8),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(height: 26, width: 1, color: Colors.grey.shade300),
          ),

          // Delivery Date
          Expanded(
            child: _buildMetricItem(
              icon: isDelivered ? Icons.task_alt_rounded : Icons.event_available_outlined,
              label: "Delivery Date",
              value: hasDelivery ? item.delivery : "-",
              iconColor: isDelivered ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
              valueColor: isDelivered ? const Color(0xFF15803D) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // Key Metrics Bar: Packages, Actual Wt
  Widget _buildMetricsBar(DocketList item) {
    final String boxes = item.noOfBoxes % 1 == 0 ? item.noOfBoxes.toInt().toString() : item.noOfBoxes.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Packages
          Expanded(
            child: _buildMetricItem(
              icon: Icons.inventory_2_outlined,
              label: "Packages",
              value: boxes,
              iconColor: const Color(0xFFE30613),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(height: 26, width: 1, color: Colors.grey.shade300),
          ),

          // Actual Wt
          Expanded(
            child: _buildMetricItem(
              icon: Icons.scale_outlined,
              label: "Actual Wt.",
              value: "${item.actuwt} kg",
              iconColor: const Color(0xFFE30613),
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
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
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
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // Modern Filter Bottom Sheet
  void _showFilterBottomSheet(BuildContext context) {
    // Sync current values into text controller
    if (misReportController.appliedDockNo.value.isNotEmpty) {
      _docketNoController.text = misReportController.appliedDockNo.value;
    }

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

                  // Header: Reset | Title | Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _docketNoController.clear();
                          misReportController.resetFilters();
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
                        "Filter MIS Report",
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

                  // Quick Date Preset Chips
                  const Text(
                    "Quick Date Presets",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetChip("Today", () {
                        final now = DateTime.now();
                        misReportController.selectedFromDate.value = now;
                        misReportController.selectedToDate.value = now;
                      }),
                      _buildPresetChip("Last 7 Days", () {
                        final now = DateTime.now();
                        misReportController.selectedFromDate.value = now.subtract(const Duration(days: 7));
                        misReportController.selectedToDate.value = now;
                      }),
                      _buildPresetChip("Last 30 Days", () {
                        final now = DateTime.now();
                        misReportController.selectedFromDate.value = now.subtract(const Duration(days: 30));
                        misReportController.selectedToDate.value = now;
                      }),
                      _buildPresetChip("This Month", () {
                        final now = DateTime.now();
                        misReportController.selectedFromDate.value = DateTime(now.year, now.month, 1);
                        misReportController.selectedToDate.value = now;
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date Range Pickers
                  const Text(
                    "Date Range",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // From Date
                      Expanded(
                        child: Obx(() {
                          final fromDate = misReportController.selectedFromDate.value;
                          return InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: bottomSheetContext,
                                firstDate: DateTime(1990),
                                lastDate: DateTime(2030),
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                                initialDate: fromDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                misReportController.selectedFromDate.value = picked;
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: fromDate != null ? const Color(0xFFE30613) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 18,
                                    color: fromDate != null ? const Color(0xFFE30613) : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "From Date",
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          fromDate != null ? DateFormat("dd MMM yyyy").format(fromDate) : "Select Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: fromDate != null ? const Color(0xFF0F172A) : Colors.grey.shade400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (fromDate != null)
                                    GestureDetector(
                                      onTap: () => misReportController.selectedFromDate.value = null,
                                      child: const Icon(Icons.cancel, size: 16, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(width: 10),

                      // To Date
                      Expanded(
                        child: Obx(() {
                          final toDate = misReportController.selectedToDate.value;
                          return InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: bottomSheetContext,
                                firstDate: DateTime(1990),
                                lastDate: DateTime(2030),
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                                initialDate: toDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                misReportController.selectedToDate.value = picked;
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: toDate != null ? const Color(0xFFE30613) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 18,
                                    color: toDate != null ? const Color(0xFFE30613) : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "To Date",
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          toDate != null ? DateFormat("dd MMM yyyy").format(toDate) : "Select Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: toDate != null ? const Color(0xFF0F172A) : Colors.grey.shade400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (toDate != null)
                                    GestureDetector(
                                      onTap: () => misReportController.selectedToDate.value = null,
                                      child: const Icon(Icons.cancel, size: 16, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Docket Number Input
                  const Text(
                    "Docket Number (Optional)",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _docketNoController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: "Enter Docket Number",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.receipt_long_rounded, color: Color(0xFFE30613), size: 20),
                      suffixIcon: _docketNoController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _docketNoController.clear();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE30613), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Apply Filter Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE30613), Color(0xFFC00511)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE30613).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final fromDate = misReportController.selectedFromDate.value;
                            final toDate = misReportController.selectedToDate.value;
                            final dockNo = _docketNoController.text.trim();

                            if (fromDate != null && toDate != null) {
                              misReportController.misReportApi(
                                fromDate: DateFormat("dd MMM yyyy").format(fromDate),
                                toDate: DateFormat("dd MMM yyyy").format(toDate),
                                dockno: dockNo,
                                isFromFilter: true,
                              );
                              Get.back();
                            } else if (fromDate == null && toDate == null && dockNo.isNotEmpty) {
                              // If only docket number provided, default to last 30 days
                              misReportController.misReportApi(
                                fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
                                toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
                                dockno: dockNo,
                                isFromFilter: true,
                              );
                              Get.back();
                            } else {
                              toastMessage(text: "Please select both From and To dates, or enter a Docket Number.", color: AppColors.redColor);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_alt_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Apply Filter",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

// Status configuration helper
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
      return const _StatusConfig(
        label: "Active",
        icon: Icons.info_outline_rounded,
        textColor: Color(0xFF334155),
        bgColor: Color(0xFFF1F5F9),
        borderColor: Color(0xFFCBD5E1),
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
