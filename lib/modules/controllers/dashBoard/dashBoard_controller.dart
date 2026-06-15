import 'package:get/get.dart';

import '../../../configs/app_endpoint.dart';
import '../../../utils/http_handler.dart';
import '../../models/dashBoard/location.dart';

class DashboardController extends GetxController {
  RxList<LocationList> location = <LocationList>[].obs;
  Rxn<LocationList> selectedLocation = Rxn<LocationList>();

  @override
  void onInit() {
    getLocation();
    super.onInit();
  }

  Future<void> getLocation() async {
    final response = await HttpHandler.getRequest(url: ApiEndPoint.location);

    if (response.statusCode == 200) {
      GetLocationMasterData getLocationMasterData = getLocationMasterDataFromJson(response.body);

      location.value = getLocationMasterData.data;
    }
  }
}
