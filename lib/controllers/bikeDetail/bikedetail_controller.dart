import 'package:get/get.dart';

import '../../user_prefernce/userPrefrence.dart';
// import '../../user_prefernce/userPrefrence.dart';

class DetailController extends GetxController {
  // The isolated active bike data
  var activeBikeData = <String, dynamic>{}.obs;
  var appCurrency = 'PKR - Rs.'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await UserPreference.getUserSettings();
    appCurrency.value = prefs['currency'] ?? 'PKR - Rs.';
  }

  // The UI will call this method exactly when the user taps "View Details"
  void setBikeData(Map<String, dynamic> bikeData) {
    activeBikeData.value = bikeData;
  }
}