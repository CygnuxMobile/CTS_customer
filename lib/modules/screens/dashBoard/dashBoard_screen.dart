import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/configs/app_text_style.dart';
import 'package:cts_customer/modules/Bindings/docket_tracking/docket_tracking_binding.dart';
import 'package:cts_customer/modules/Bindings/login/login_binding.dart';
import 'package:cts_customer/modules/Bindings/mis_report/mis_report_binding.dart';
import 'package:cts_customer/modules/controllers/dashBoard/dashBoard_controller.dart';
import 'package:cts_customer/modules/screens/docket_tracking/docket_tracking_screen.dart';
import 'package:cts_customer/modules/screens/login/login_screen.dart';
import 'package:cts_customer/modules/screens/mis_report_screen/mis_report_screen.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../notification/notification_history_screen.dart';
import '../../controllers/notification/notification_history_controller.dart';

import '../../../configs/app_shared_key.dart';
import '../../models/dashBoard/location.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  DashboardController dashboardController = Get.find<DashboardController>();

  @override
  void initState() {
    Pref.getData(LocalStorageKey.locationCode) != null && Pref.getData(LocalStorageKey.locationName) != null
        ? dashboardController.selectedLocation.value = LocationList(
            locCode: Pref.getData(LocalStorageKey.locationCode),
            locName: Pref.getData(LocalStorageKey.locationName),
          )
        : null;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 2.0,
        child: Column(
          children: [
            Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE30613), // Red color from login page
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      Pref.getData(LocalStorageKey.fullName),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    /*Text(
                      Pref.getData(LocalStorageKey.userId),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),*/
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Pref.clearData();
                Get.offAll(() => LoginScreen(), binding: LoginBinding());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.primaryColor.withValues(alpha: 0.1)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("Logout", style: AppTextStyle.bold.copyWith(color: AppColors.primaryColor)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE30613), // Red color from login page
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Welcome,",
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await Get.to(() => const NotificationHistoryScreen());
                                    // Refresh count when coming back
                                    Get.find<NotificationHistoryController>().fetchNotifications();
                                  },
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                                ),
                                Obx(() {
                                  final notificationController = Get.put(NotificationHistoryController());
                                  if (notificationController.unreadCount.value == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFE30613), width: 1),
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
                            const SizedBox(width: 8),
                            // Profile/User Icon
                            InkWell(
                              onTap: () {
                                scaffoldKey.currentState!.openDrawer();
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, color: Color(0xFFE30613)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Pref.getData(LocalStorageKey.fullName),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    // Location Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Obx(() {
                        return DropdownSearch<LocationList>(
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "Search Location",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          items: dashboardController.location,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: "Select Location",
                              hintStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                              prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          itemAsString: (v) => "${v.locName}",
                          selectedItem: dashboardController.selectedLocation.value,
                          onChanged: (LocationList? value) {
                            dashboardController.selectedLocation.value = value!;
                            Pref.setData(LocalStorageKey.locationName, value.locName);
                            Pref.setData(LocalStorageKey.locationCode, value.locCode);
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFA0816), Color(0xFFC00511)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: const Color(0xFFE30613).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (dashboardController.selectedLocation.value == null) {
                              toastMessage(text: "Please Select Location", color: AppColors.redColor);
                            } else {
                              Get.to(
                                () => DocketTrackingScreen(locCode: dashboardController.selectedLocation.value?.locCode),
                                binding: DocketTrackingBinding(),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.track_changes, color: Colors.white, size: 28),
                                    SizedBox(width: 15),
                                    Text(
                                      "Docket Tracking",
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFA0816), Color(0xFFC00511)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: const Color(0xFFE30613).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (dashboardController.selectedLocation.value == null) {
                              toastMessage(text: "Please Select Location", color: AppColors.redColor);
                            } else {
                              Get.to(
                                    () => MisReportScreen(),
                                binding: MisReportBinding(),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.track_changes, color: Colors.white, size: 28),
                                    SizedBox(width: 15),
                                    Text(
                                      "MIS Report",
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
