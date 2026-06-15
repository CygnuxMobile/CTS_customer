import 'package:get/get.dart';
import '../../controllers/mis_report/mis_report_controller.dart';

class MisReportBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => MisReportController());
  }
}
