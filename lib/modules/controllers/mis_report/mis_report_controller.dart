import 'dart:convert';

import 'package:cts_customer/configs/app_shared_key.dart';
import 'package:get/get.dart';

import '../../../configs/app_endpoint.dart';
import '../../../utils/http_handler.dart';
import '../../models/mis_report/mis_report_model.dart';

class MisReportController extends GetxController {
  RxBool isLoading = false.obs;

  RxString errorMessage = ''.obs;
  RxList<DocketList> docketLists = <DocketList>[].obs;
  Rxn<DateTime> selectedFromDate = Rxn<DateTime>();
  Rxn<DateTime> selectedToDate = Rxn<DateTime>();

  Future<void> misReportApi({
    String? dockno,
    String? fromDate,
    String? toDate,
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
          "dockno": dockno,
          "imstype": "M",
        },
      );

      if (response.statusCode == 200) {
        MisReportResponse misReportResponse = misReportResponseFromJson(
          response.body,
        );
        docketLists.value = misReportResponse.misReportList.docketLists;
      } else {
        errorMessage.value = "Something went wrong. Try again later.";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong. Try again later.";
    } finally {
      isLoading.value = false;
    }
  }
}
