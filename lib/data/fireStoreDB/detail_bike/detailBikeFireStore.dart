import 'package:get/get.dart';
import '../../../user_prefernce/userPrefrence.dart';


class DetailController extends GetxController {
  // The isolated active bike data
  var activeBikeData = <String, dynamic>{}.obs;
  var appCurrency = 'PKR - Rs.'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrency();

    // WAKE UP AND GET DATA:
    // Safely grab the bike data passed from the BikesScreen navigation
    if (Get.arguments != null) {
      activeBikeData.value = Get.arguments as Map<String, dynamic>;
    }
  }

  Future<void> _loadCurrency() async {
    final prefs = await UserPreference.getUserSettings();
    appCurrency.value = prefs['currency'] ?? 'PKR - Rs.';
  }

  // Update locally and notify UI if needed later
  void setBikeData(Map<String, dynamic> bikeData) {
    activeBikeData.value = bikeData;
  }
}