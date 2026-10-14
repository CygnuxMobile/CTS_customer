import 'dart:convert';

import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:cts_customer/modules/models/dashBoard/location.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_endpoint.dart';
import '../../../utils/http_handler.dart';
import '../../models/docket_tracking/docket_tracking_model.dart';

class DocketTrackingController extends GetxController {
  var isLoading = false.obs;
  var docketList = <DocketList>[].obs;
  var errorMessage = "".obs;
  RxList<LocationList> location = <LocationList>[].obs;
  Rxn<LocationList> selectedLocation = Rxn<LocationList>();
  Rxn<DateTime> selectedFromDate = Rxn<DateTime>();
  Rxn<DateTime> selectedToDate = Rxn<DateTime>();

  // Filter and search state
  var searchQuery = "".obs;
  var isFilterApplied = false.obs;
  var appliedLocCode = "".obs;
  Rxn<DateTime> appliedFromDate = Rxn<DateTime>();
  Rxn<DateTime> appliedToDate = Rxn<DateTime>();
  Rxn<LocationList> appliedLocation = Rxn<LocationList>();

  List<DocketList> get filteredDocketList {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return docketList;
    }
    return docketList.where((item) {
      final dockNo = item.dockno.toLowerCase();
      final from = item.froMLoc.toLowerCase();
      final to = item.tOLoc.toLowerCase();
      final consignor = item.csgnnm.toLowerCase();
      final status = item.oPStatus.toLowerCase();
      return dockNo.contains(query) ||
          from.contains(query) ||
          to.contains(query) ||
          consignor.contains(query) ||
          status.contains(query);
    }).toList();
  }

  Future<void> docketTrackingApi({
    String? locCode,
    String? fromDate,
    String? toDate,
    bool isFromFilterTab = false,
    bool isForDelivery = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await HttpHandler.postRequest(
        url: ApiEndPoint.docketTracking,
        body: isFromFilterTab
            ? {
                "partY_CODE": Pref.getData(LocalStorageKey.userId),
                "fromDate": fromDate,
                "toDate": toDate,
                "orgncd": isForDelivery == false
                    ? (locCode == null || locCode.trim().isEmpty ? "" : locCode)
                    : "",
                "destcd": isForDelivery == true
                    ? (locCode == null || locCode.trim().isEmpty ? "" : locCode)
                    : "",
                "from_loc": "",
                "to_loc": "",
                "bkgdelloc": "",
              }
            : {
                "partY_CODE": Pref.getData(LocalStorageKey.userId),
                "fromDate": fromDate,
                "toDate": toDate,
                "orgncd": (locCode == null || locCode.trim().isEmpty ? "" : locCode),
                "destcd": "",
                "from_loc": "",
                "to_loc": "",
                "bkgdelloc": "",
              },
      );

      if (response.statusCode == 200) {
        final data = DocketTrackingResponse.fromJson(jsonDecode(response.body));

        if (data.data != null && data.data!.docketLists.isNotEmpty) {
          docketList.assignAll(data.data!.docketLists);
        } else {
          docketList.clear();
          errorMessage.value = "No records found";
        }

        if (isFromFilterTab) {
          isFilterApplied.value = true;
          appliedLocCode.value = locCode ?? "";
          appliedFromDate.value = selectedFromDate.value;
          appliedToDate.value = selectedToDate.value;
          appliedLocation.value = selectedLocation.value;
          Get.back();
        }
      } else {
        errorMessage.value = "Something went wrong. Try again later.";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters({String? defaultLocCode}) {
    selectedToDate.value = null;
    selectedFromDate.value = null;
    selectedLocation.value = null;
    isFilterApplied.value = false;
    appliedLocCode.value = "";
    appliedFromDate.value = null;
    appliedToDate.value = null;
    appliedLocation.value = null;
    searchQuery.value = "";

    docketTrackingApi(
      locCode: defaultLocCode,
      fromDate: DateFormat("dd MMM yyyy").format(DateTime.now().subtract(const Duration(days: 30))),
      toDate: DateFormat("dd MMM yyyy").format(DateTime.now()),
    );
  }
}
