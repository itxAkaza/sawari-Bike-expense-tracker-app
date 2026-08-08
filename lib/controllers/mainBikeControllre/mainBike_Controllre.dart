import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/mainBikes/mainBikesFireStore.dart';
import '../../models/bike_model.dart';

// import 'main_bikes_firestore_service.dart';
// import 'bike_model.dart';
// import '../../Utiles/utiles.dart';

class MainBikesController extends GetxController {
  final MainBikesFirestoreService _dbService = MainBikesFirestoreService();
  StreamSubscription? _bikesSubscription;

  // --- Global State ---
  // The single source of truth for all bikes
  final bikes = <BikeModel>[].obs;

  // Only storing the String ID of the active bike
  final selectedBikeId = RxnString();

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initBikesStream();
  }

  Future<void> _initBikesStream() async {
    try {
      // 1. Load the last selected bike ID from local storage
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('active_bike_id');
      if (savedId != null && savedId.isNotEmpty) {
        selectedBikeId.value = savedId;
      }

      // 2. Start listening to the mapped Firestore stream
      _bikesSubscription = _dbService.getUserBikesStream().listen(
            (bikeList) {
          // Update the global list
          bikes.assignAll(bikeList);

          // Auto-select logic:
          // If no bike is selected, OR the selected bike was deleted from the database
          if (bikeList.isNotEmpty) {
            bool activeBikeExists = bikeList.any((b) => b!.bikeId == selectedBikeId.value);

            if (!activeBikeExists) {
              setAsActiveBike(bikeList.first.bikeId);
            }
          } else {
            // No bikes left in the garage
            selectedBikeId.value = null;
            _clearSavedBikeId();
          }

          isLoading.value = false;
        },
        onError: (error) {
          Utils.toastMesseges('err_stream_network'.tr);
          isLoading.value = false;
        },
      );
    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
      isLoading.value = false;
    }
  }

  // --- Actions ---

  /// Called when the user taps a bike card to switch their active bike
  Future<void> setAsActiveBike(String bikeId) async {
    selectedBikeId.value = bikeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_bike_id', bikeId);
  }

  Future<void> _clearSavedBikeId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_bike_id');
  }

  @override
  void onClose() {
    _bikesSubscription?.cancel();
    super.onClose();
  }
}