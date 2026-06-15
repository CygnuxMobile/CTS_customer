import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_text_style.dart';
import '../../controllers/mis_report/mis_report_controller.dart';

class MisReportScreen extends StatefulWidget {
  const MisReportScreen({super.key});

  @override
  State<MisReportScreen> createState() => _MisReportScreenState();
}

class _MisReportScreenState extends State<MisReportScreen> {
  MisReportController misReportController = Get.find<MisReportController>();
  final TextEditingController _docketNoController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    misReportController.misReportApi(
      fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(Duration(days: 30))),
      toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
      dockno: "",
    );
    super.initState();
  }

  @override
  void dispose() {
    _docketNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MIS Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  isScrollControlled: true,
                  builder: (context) {
                    return PopScope(
                      canPop: false,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, left: 10, right: 10),
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
                                        await misReportController
                                            .misReportApi(
                                              dockno: "",
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
                                        misReportController.selectedToDate.value = null;
                                        misReportController.selectedFromDate.value = null;
                                        _docketNoController.clear();
                                        Get.back();
                                      },
                                      child: const Icon(Icons.cancel_outlined),
                                    ),
                                  ],
                                ),
                              ),
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
                                    misReportController.selectedFromDate.value = selectedFromDate;
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
                                            misReportController.selectedFromDate.value != null
                                                ? DateFormat("dd MMM yyyy").format(misReportController.selectedFromDate.value!)
                                                : "Select From date",
                                            style: AppTextStyle.regular.copyWith(color: AppColors.blackColor),
                                          );
                                        }),
                                        const Spacer(),

                                        ///Added 'const'
                                        Obx(
                                          () => misReportController.selectedFromDate.value != null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    misReportController.selectedFromDate.value = null;
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
                                    misReportController.selectedToDate.value = selectedToDate;
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

                                        /// Added 'const'
                                        Obx(() {
                                          return Text(
                                            misReportController.selectedToDate.value != null
                                                ? DateFormat("dd MMM yyyy").format(misReportController.selectedToDate.value!)
                                                : "Select To date",
                                            style: AppTextStyle.regular.copyWith(color: AppColors.blackColor),
                                          );
                                        }),
                                        const Spacer(),
                                        Obx(
                                          () => misReportController.selectedToDate.value != null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    misReportController.selectedToDate.value = null;
                                                  },
                                                  child: const Icon(Icons.cancel), // Added 'const'
                                                )
                                              : SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _docketNoController,
                                decoration: InputDecoration(
                                  labelText: "Docket Number",
                                  hintText: "Enter Docket Number",
                                  prefixIcon: const Icon(Icons.receipt_long),
                                  filled: true,
                                  fillColor: AppColors.whiteColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                                      if (misReportController.selectedFromDate.value != null && misReportController.selectedToDate.value != null) {
                                        misReportController.misReportApi(
                                          fromDate: misReportController.selectedFromDate.value != null
                                              ? DateFormat("dd MMM yyyy").format(misReportController.selectedFromDate.value!)
                                              : DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
                                          toDate: misReportController.selectedToDate.value != null
                                              ? DateFormat("dd MMM yyyy").format(misReportController.selectedToDate.value!)
                                              : DateFormat("dd MMM yyyy").format(DateTime.now()),
                                          dockno: _docketNoController.text,
                                        );
                                      } else if (misReportController.selectedFromDate.value == null &&
                                          misReportController.selectedToDate.value == null &&
                                          _docketNoController.text.isNotEmpty) {
                                        misReportController.misReportApi(
                                          fromDate: misReportController.selectedFromDate.value != null
                                              ? DateFormat("dd MMM yyyy").format(misReportController.selectedFromDate.value!)
                                              : DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
                                          toDate: misReportController.selectedToDate.value != null
                                              ? DateFormat("dd MMM yyyy").format(misReportController.selectedToDate.value!)
                                              : DateFormat("dd MMM yyyy").format(DateTime.now()),
                                          dockno: _docketNoController.text,
                                        );
                                      } else {
                                        Get.snackbar('Error', 'Please select a date range.',backgroundColor: Colors.red);
                                      }
                                      _docketNoController.clear();
                                      Get.back();
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
        if (misReportController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (misReportController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(misReportController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 16)),
          );
        }

        if (misReportController.docketLists.isEmpty) {
          return const Center(
            child: Text("No dockets found. Please check back later.", style: TextStyle(color: Colors.black54)),
          );
        }
        return ListView.builder(
          itemCount: misReportController.docketLists.length,
          itemBuilder: (context, index) {
            final report = misReportController.docketLists[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Docket No: ${report.dockno}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(report.docketDate, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        "Status: ${report.status}",
                        style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Divider(height: 24),
                    // From and To Cities
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("From", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(report.fromCity, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward, color: Colors.red, size: 20),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("To", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(report.toCity, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Consignor and Consignee
                    Row(
                      children: [
                        Expanded(child: _buildPartyInfo("Consignor", report.consignorName)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPartyInfo("Consignee", report.consigneeName)),
                      ],
                    ),
                    const Divider(height: 24),
                    // Package and Weight info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailItem(Icons.inventory_2_outlined, "Packages", "${report.noOfBoxes}"),
                        _buildDetailItem(Icons.scale_outlined, "Actual Wt.", "${report.actuwt} kg"),
                        if (report.delivery.isNotEmpty) _buildDetailItem(Icons.event_available_outlined, "Delivery Date", report.delivery),
                      ],
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

  Widget _buildPartyInfo(String title, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.red, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
