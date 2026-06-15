import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/configs/app_endpoint.dart';
import 'package:cts_customer/configs/app_text_style.dart';
import 'package:cts_customer/modules/controllers/dashBoard/dashBoard_controller.dart';
import 'package:cts_customer/modules/controllers/docket_tracking/docket_tracking_controller.dart';
import 'package:cts_customer/modules/models/dashBoard/location.dart';
import 'package:cts_customer/modules/screens/Pod_view_screen/pod_view_screen.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum FilterType { booking, delivery }

class DocketTrackingScreen extends StatefulWidget {
  final String? locCode;

  DocketTrackingScreen({super.key, this.locCode});

  @override
  State<DocketTrackingScreen> createState() => _DocketTrackingScreenState();
}

class _DocketTrackingScreenState extends State<DocketTrackingScreen> {
  final DocketTrackingController docketTrackingController = Get.put(DocketTrackingController());

  @override
  void initState() {
    docketTrackingController.docketTrackingApi(
      locCode: widget.locCode,
      fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(Duration(days: 30))),
      toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Docket Tracking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                DashboardController dashboardController = Get.find<DashboardController>();

                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  builder: (context) {
                    return PopScope(
                      canPop: false,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, left: 10, right: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await docketTrackingController
                                            .docketTrackingApi(
                                              locCode: widget.locCode,
                                              fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(Duration(days: 30))),
                                              toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
                                            )
                                            .whenComplete(() => Get.back());
                                      },
                                      child: Text("Clear", style: AppTextStyle.regular.copyWith(fontSize: 18, color: AppColors.primaryColor)),
                                    ),
                                    Text("Filter", style: AppTextStyle.light.copyWith(fontSize: 25)),
                                    GestureDetector(
                                      onTap: () {
                                        docketTrackingController.selectedToDate.value = null;
                                        docketTrackingController.selectedFromDate.value = null;
                                        docketTrackingController.selectedLocation.value = null;
                                        docketTrackingController.filterType.value = FilterType.booking;
                                        Get.back();
                                      },
                                      child: const Icon(Icons.cancel_outlined), // Added 'const'
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() {
                                return RadioGroup<FilterType>(
                                  groupValue: docketTrackingController.filterType.value,
                                  onChanged: (FilterType? value) {
                                    docketTrackingController.filterType.value = value!;
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<FilterType>(
                                            value: FilterType.booking,
                                            groupValue: docketTrackingController.filterType.value,
                                            onChanged: (FilterType? value) {
                                              docketTrackingController.filterType.value = value!;
                                            },
                                            activeColor: AppColors.primaryColor,
                                          ),
                                          Text('Booking', style: AppTextStyle.regular.copyWith(color: AppColors.blackColor)),
                                        ],
                                      ),

                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<FilterType>(
                                            value: FilterType.delivery,
                                            groupValue: docketTrackingController.filterType.value,
                                            onChanged: (FilterType? value) {
                                              docketTrackingController.filterType.value = value!;
                                            },
                                            activeColor: AppColors.primaryColor,
                                          ),
                                          Text('Delivery', style: AppTextStyle.regular.copyWith(color: AppColors.blackColor)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              Obx(() {
                                return DropdownSearch<LocationList>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search Location",
                                        hintStyle: AppTextStyle.regular.copyWith(color: AppColors.blackColor),
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
                                  selectedItem: docketTrackingController.selectedLocation.value,
                                  onChanged: (LocationList? value) {
                                    docketTrackingController.selectedLocation.value = value!;
                                  },
                                );
                              }),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  DateTime? selectedFromDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime(2030),
                                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                                    initialDate: DateTime.now(),
                                  );
                                  if (selectedFromDate != null) {
                                    docketTrackingController.selectedFromDate.value = selectedFromDate;
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: Get.width,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.whiteColor),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12.0, right: 12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.date_range),
                                        // Added 'const'
                                        const SizedBox(width: 15),
                                        // Added 'const'
                                        Obx(() {
                                          return Text(
                                            docketTrackingController.selectedFromDate.value != null
                                                ? DateFormat("dd MMM yyyy").format(docketTrackingController.selectedFromDate.value!)
                                                : "Select From date",
                                            style: AppTextStyle.regular.copyWith(color: AppColors.blackColor),
                                          );
                                        }),
                                        const Spacer(),
                                        // Added 'const'
                                        Obx(
                                          () => docketTrackingController.selectedFromDate.value != null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    docketTrackingController.selectedFromDate.value = null;
                                                  },
                                                  child: const Icon(Icons.cancel),
                                                )
                                              : const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  DateTime? selectedToDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime(2030),
                                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                                    initialDate: DateTime.now(),
                                  );
                                  if (selectedToDate != null) {
                                    docketTrackingController.selectedToDate.value = selectedToDate;
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: Get.width,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.whiteColor),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12.0, right: 12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.date_range),
                                        // Added 'const'
                                        const SizedBox(width: 15),
                                        // Added 'const'
                                        Obx(() {
                                          return Text(
                                            docketTrackingController.selectedToDate.value != null
                                                ? DateFormat("dd MMM yyyy").format(docketTrackingController.selectedToDate.value!)
                                                : "Select To date",
                                            style: AppTextStyle.regular.copyWith(color: AppColors.blackColor),
                                          );
                                        }),
                                        const Spacer(),
                                        // Added 'const'
                                        Obx(
                                          () => docketTrackingController.selectedToDate.value != null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    docketTrackingController.selectedToDate.value = null;
                                                  },
                                                  child: const Icon(Icons.cancel), // Added 'const'
                                                )
                                              : const SizedBox(), // Added 'const'
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Container(
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
                                      if (docketTrackingController.selectedLocation.value != null &&
                                          docketTrackingController.selectedFromDate.value != null &&
                                          docketTrackingController.selectedToDate.value != null) {
                                        docketTrackingController.docketTrackingApi(
                                          locCode: docketTrackingController.selectedLocation.value!.locCode,
                                          fromDate: DateFormat("dd MMM yyyy").format(docketTrackingController.selectedFromDate.value!),
                                          toDate: DateFormat("dd MMM yyyy").format(docketTrackingController.selectedToDate.value!),
                                          isFromFilterTab: true,
                                          isForDelivery: docketTrackingController.filterType.value == FilterType.delivery ? true : false,
                                        );
                                      } else {
                                        Get.snackbar('Error', 'Please select a location, from date, and to date.');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: const Padding(
                                      // Added 'const'
                                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Apply Filter",
                                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Added 'const'
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(Icons.filter_alt, color: AppColors.whiteColor),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xFFE30613),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (docketTrackingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (docketTrackingController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(docketTrackingController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 16)),
          );
        }

        if (docketTrackingController.docketList.isEmpty) {
          return const Center(
            child: Text("No dockets found. Please check back later.", style: TextStyle(color: Colors.black54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: docketTrackingController.docketList.length,
          itemBuilder: (context, index) {
            final item = docketTrackingController.docketList[index];

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Docket No: ${item.dockno}",
                          style: const TextStyle(color: Color(0xFFE30613), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: item.podlink == null || item.podlink.toString().isEmpty
                              ? () {
                                  toastMessage(text: "No POD Found", color: AppColors.redColor);
                                }
                              : () {
                                  Get.to(
                                    () =>
                                        PodViewScreen(podImage: "http://cts.cygnux.in/Images/FMScanDocument/${item.podlink}", fileName: item.dockno),
                                  );
                                },
                          child: Icon(
                            item.podlink == null || item.podlink.toString().isEmpty ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    _buildInfoRow(label: 'From:', value: item.froMLoc, icon: Icons.location_on_outlined),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'To:', value: item.tOLoc, icon: Icons.location_on),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'EDD:', value: item.edd, icon: Icons.calendar_today_outlined),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'ADD:', value: item.add, icon: Icons.calendar_today),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'Booking Date:', value: item.dockdt, icon: Icons.calendar_today),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'Consignor Name:', value: item.csgnnm, icon: Icons.person),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'QTY:', value: item.pkgsno.toString(), icon: Icons.inventory_2),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'Weight:', value: item.actuwt.toString(), icon: Icons.scale),
                    const SizedBox(height: 8),

                    _buildInfoRow(label: 'Amount:', value: item.dkttot.toString(), icon: Icons.currency_rupee),

                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          item.oPStatus,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInfoRow({required String label, required String? value, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value ?? ' ',
            style: const TextStyle(color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
