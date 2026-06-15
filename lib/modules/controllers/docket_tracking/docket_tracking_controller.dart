import 'dart:convert';

import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:cts_customer/modules/models/dashBoard/location.dart';
import 'package:cts_customer/modules/screens/docket_tracking/docket_tracking_screen.dart';
import 'package:get/get.dart';

import '../../../configs/app_endpoint.dart';
import '../../../utils/http_handler.dart';
import '../../models/docket_tracking/docket_tracking_model.dart';

class DocketTrackingController extends GetxController {
  var isLoading = false.obs;
  var docketList = <DocketList>[].obs;
  var errorMessage = "".obs;
  RxList<LocationList> location = <LocationList>[].obs;
  Rxn<LocationList> selectedLocation = Rxn<LocationList>();
  Rx<FilterType> filterType = FilterType.booking.obs;
  Rxn<DateTime> selectedFromDate = Rxn<DateTime>();
  Rxn<DateTime> selectedToDate = Rxn<DateTime>();

  Future<void> docketTrackingApi({String? locCode, String? fromDate, String? toDate, bool isFromFilterTab = false, bool isForDelivery = false}) async {
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
                    ? locCode == null || locCode.trim() == "" || locCode.isEmpty
                          ? ""
                          : locCode
                    : "",
                "destcd": isForDelivery == true
                    ? locCode == null || locCode.trim() == "" || locCode.isEmpty
                          ? ""
                          : locCode
                    : "",
                "from_loc": "",
                "to_loc": "",
                "bkgdelloc": "",
              }
            : {
                "partY_CODE": Pref.getData(LocalStorageKey.userId),
                "fromDate": fromDate,
                "toDate": toDate,
                "orgncd": locCode == null || locCode.trim() == "" || locCode.isEmpty ? "" : locCode,
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
          errorMessage.value = "No records found";
        }
        isFromFilterTab ? Get.back() : null;
      } else {
        errorMessage.value = "Something went wrong. Try again later.";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
