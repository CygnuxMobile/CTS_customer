import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_endpoint.dart';
import '../../../utils/http_handler.dart';
import '../../models/mis_report/mis_report_model.dart';

class MisReportController extends GetxController {
  RxBool isLoading = false.obs;

  RxString errorMessage = ''.obs;
  RxList<DocketList> docketLists = <DocketList>[].obs;
  Rxn<DateTime> selectedFromDate = Rxn<DateTime>();
  Rxn<DateTime> selectedToDate = Rxn<DateTime>();

  // Search and filter tracking state
  RxString searchQuery = "".obs;
  RxBool isFilterApplied = false.obs;
  Rxn<DateTime> appliedFromDate = Rxn<DateTime>();
  Rxn<DateTime> appliedToDate = Rxn<DateTime>();
  RxString appliedDockNo = "".obs;

  List<DocketList> get filteredDocketList {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return docketLists;
    }
    return docketLists.where((item) {
      final dockNo = item.dockno.toLowerCase();
      final from = item.fromCity.toLowerCase();
      final to = item.toCity.toLowerCase();
      final consignor = item.consignorName.toLowerCase();
      final consignee = item.consigneeName.toLowerCase();
      final status = item.status.toLowerCase();
      final edd = item.edd.toLowerCase();
      final delivery = item.delivery.toLowerCase();
      return dockNo.contains(query) ||
          from.contains(query) ||
          to.contains(query) ||
          consignor.contains(query) ||
          consignee.contains(query) ||
          status.contains(query) ||
          edd.contains(query) ||
          delivery.contains(query);
    }).toList();
  }

  Future<void> misReportApi({
    String? dockno,
    String? fromDate,
    String? toDate,
    bool isFromFilter = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await HttpHandler.postRequest(
        url: ApiEndPoint.GetCustMISReport,
        body: {
          "fromDate": fromDate,
          "toDate": toDate,
          "partY_CODE": Pref.getData(LocalStorageKey.userId),
          "dockno": dockno ?? "",
          "imstype": "M",
        },
      );

      if (response.statusCode == 200) {
        MisReportResponse misReportResponse = misReportResponseFromJson(
          response.body,
        );
        docketLists.value = misReportResponse.misReportList.docketLists;

        if (isFromFilter) {
          isFilterApplied.value = true;
          appliedFromDate.value = selectedFromDate.value;
          appliedToDate.value = selectedToDate.value;
          appliedDockNo.value = dockno ?? "";
        }
      } else {
        errorMessage.value = "Something went wrong. Try again later.";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong. Try again later.";
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    selectedFromDate.value = null;
    selectedToDate.value = null;
    isFilterApplied.value = false;
    appliedFromDate.value = null;
    appliedToDate.value = null;
    appliedDockNo.value = "";
    searchQuery.value = "";

    misReportApi(
      fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
      toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
      dockno: "",
    );
  }
}

