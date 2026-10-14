import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/configs/app_images.dart';
import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:cts_customer/modules/Bindings/docket_tracking/docket_tracking_binding.dart';
import 'package:cts_customer/modules/Bindings/login/login_binding.dart';
import 'package:cts_customer/modules/Bindings/mis_report/mis_report_binding.dart';
import 'package:cts_customer/modules/controllers/dashBoard/dashBoard_controller.dart';
import 'package:cts_customer/modules/controllers/notification/notification_history_controller.dart';
import 'package:cts_customer/modules/models/dashBoard/location.dart';
import 'package:cts_customer/modules/screens/docket_tracking/docket_tracking_screen.dart';
import 'package:cts_customer/modules/screens/login/login_screen.dart';
import 'package:cts_customer/modules/screens/mis_report_screen/mis_report_screen.dart';
import 'package:cts_customer/modules/screens/notification/notification_history_screen.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardController dashboardController = Get.find<DashboardController>();

  @override
  void initState() {
    if (Pref.getData(LocalStorageKey.locationCode) != null &&
        Pref.getData(LocalStorageKey.locationName) != null) {
      dashboardController.selectedLocation.value = LocationList(
        locCode: Pref.getData(LocalStorageKey.locationCode),
        locName: Pref.getData(LocalStorageKey.locationName),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: _buildDrawer(context),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              _buildHeader(context),

              // Modules Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Operations & Services",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE30613).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "2 Modules",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE30613),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Select an operation to manage your consignments",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Module 1: Docket Tracking
                    _buildServiceCard(
                      title: "Docket Tracking",
                      subtitle: "Track live status, checkpoints & view POD documents",
                      icon: Icons.local_shipping_rounded,
                      gradient: const [Color(0xFFE30613), Color(0xFFB0050F)],
                      features: ["Live Tracking", "POD View"],
                      onTap: () {
                        if (dashboardController.selectedLocation.value == null) {
                          toastMessage(text: "Please Select Location", color: AppColors.redColor);
                        } else {
                          Get.to(
                            () => DocketTrackingScreen(
                              locCode: dashboardController.selectedLocation.value?.locCode,
                            ),
                            binding: DocketTrackingBinding(),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Module 2: MIS Report
                    _buildServiceCard(
                      title: "MIS Report",
                      subtitle: "Comprehensive dispatch summaries, reports & analytics",
                      icon: Icons.assessment_rounded,
                      gradient: const [Color(0xFF1E293B), Color(0xFF334155)],
                      features: ["Summary Reports", "Date Filters"],
                      onTap: () {
                        if (dashboardController.selectedLocation.value == null) {
                          toastMessage(text: "Please Select Location", color: AppColors.redColor);
                        } else {
                          Get.to(
                            () => const MisReportScreen(),
                            binding: MisReportBinding(),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Header Section
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + 12,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Notification/Profile Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome,",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Pref.getData(LocalStorageKey.fullName) ?? "Customer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Notification Button with live badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await Get.to(() => const NotificationHistoryScreen());
                            Get.find<NotificationHistoryController>().fetchNotifications();
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Obx(() {
                        final notificationController = Get.put(NotificationHistoryController());
                        if (notificationController.unreadCount.value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE30613), width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '${notificationController.unreadCount.value}',
                                style: const TextStyle(
                                  color: Color(0xFFE30613),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Profile / Menu Button
                  InkWell(
                    onTap: () => scaffoldKey.currentState!.openDrawer(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person, color: Color(0xFFE30613), size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location Selector Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() {
              return DropdownSearch<LocationList>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,
                  ),
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Location...",
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFE30613), width: 1.5),
                      ),
                    ),
                  ),
                ),
                items: dashboardController.location,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Select Location",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFE30613),
                      size: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                itemAsString: (v) => "${v.locName}",
                selectedItem: dashboardController.selectedLocation.value,
                onChanged: (LocationList? value) {
                  if (value != null) {
                    dashboardController.selectedLocation.value = value;
                    Pref.setData(LocalStorageKey.locationName, value.locName);
                    Pref.setData(LocalStorageKey.locationCode, value.locCode);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Modern Service Card for the two modules
  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon container with gradient
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: gradient.first.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: gradient.first,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Feature chips row
                Row(
                  children: [
                    for (final feature in features)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: gradient.first,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                feature,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern Drawer Widget
  Widget _buildDrawer(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE30613), Color(0xFFB0050F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 22,
              ),
              child: Stack(
                children: [
                  // Subtle brand logo watermark in corner
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(
                        AppImages.logo,
                        height: 85,
                        width: 85,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_rounded, color: Color(0xFFE30613), size: 30),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  "Customer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        Pref.getData(LocalStorageKey.fullName) ?? "Customer",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Pref.getData(LocalStorageKey.userId) != null &&
                                Pref.getData(LocalStorageKey.userId).toString().isNotEmpty
                            ? "ID: ${Pref.getData(LocalStorageKey.userId)}"
                            : "Chintamani Transport Services",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Active Branch Info Card
            Obx(() {
              final loc = dashboardController.selectedLocation.value;
              if (loc == null) return const SizedBox(height: 8);
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30613).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFE30613)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ACTIVE BRANCH",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            loc.locName ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Drawer Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      "MENU",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerTile(
                    icon: Icons.dashboard_rounded,
                    title: "Dashboard",
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerTile(
                    icon: Icons.local_shipping_rounded,
                    title: "Docket Tracking",
                    onTap: () {
                      Navigator.pop(context);
                      if (dashboardController.selectedLocation.value == null) {
                        toastMessage(text: "Please Select Location", color: AppColors.redColor);
                      } else {
                        Get.to(
                          () => DocketTrackingScreen(
                            locCode: dashboardController.selectedLocation.value?.locCode,
                          ),
                          binding: DocketTrackingBinding(),
                        );
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.assessment_rounded,
                    title: "MIS Report",
                    onTap: () {
                      Navigator.pop(context);
                      if (dashboardController.selectedLocation.value == null) {
                        toastMessage(text: "Please Select Location", color: AppColors.redColor);
                      } else {
                        Get.to(
                          () => const MisReportScreen(),
                          binding: MisReportBinding(),
                        );
                      }
                    },
                  ),
                  Obx(() {
                    final notificationController = Get.put(NotificationHistoryController());
                    final unread = notificationController.unreadCount.value;
                    return _buildDrawerTile(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      badgeCount: unread > 0 ? unread : null,
                      onTap: () async {
                        Navigator.pop(context);
                        await Get.to(() => const NotificationHistoryScreen());
                        Get.find<NotificationHistoryController>().fetchNotifications();
                      },
                    );
                  }),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Logout Action with Safe Area handling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  Get.defaultDialog(
                    title: "Logout",
                    titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    middleText: "Are you sure you want to logout?",
                    middleTextStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    textConfirm: "Yes, Logout",
                    confirmTextColor: Colors.white,
                    buttonColor: const Color(0xFFE30613),
                    textCancel: "Cancel",
                    cancelTextColor: Colors.grey.shade700,
                    onConfirm: () {
                      Get.back();
                      Pref.clearData();
                      Get.offAll(() => LoginScreen(), binding: LoginBinding());
                    },
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE30613).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE30613).withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Color(0xFFE30613), size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Color(0xFFE30613),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Version info above navigation bar
            Text(
              "CTS Customer v1.0.8",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Generous padding so it never touches system navigation buttons
            SizedBox(height: bottomInset > 0 ? 8 : 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? const Color(0xFFE30613).withValues(alpha: 0.08) : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFE30613) : const Color(0xFF475569),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE30613) : const Color(0xFF1E293B),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE30613),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        visualDensity: const VisualDensity(vertical: -1),
      ),
    );
  }
}
