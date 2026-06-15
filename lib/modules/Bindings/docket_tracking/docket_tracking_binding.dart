import 'package:cts_customer/modules/controllers/docket_tracking/docket_tracking_controller.dart';
import 'package:get/get.dart';

class DocketTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DocketTrackingController());
  }
}
