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
  final bikes = <BikeModel>[].obs;
  final selectedBikeId = RxnString();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initBikesStream();
  }

  // --- Helpers & Calculations ---

  /// Dynamically finds and returns the actual BikeModel object based on the selected ID
  BikeModel? get activeBike {
    if (selectedBikeId.value == null || bikes.isEmpty) return null;

    try {
      // Searches the list for the bike that matches the active ID
      return bikes.firstWhere((b) => b.bikeId == selectedBikeId.value);
    } catch (e) {
      return null; // Failsafe if the bike isn't found
    }
  }

  Future<void> _initBikesStream() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('active_bike_id');
      if (savedId != null && savedId.isNotEmpty) {
        selectedBikeId.value = savedId;
      }

      _bikesSubscription = _dbService.getUserBikesStream().listen(
            (bikeList) {
          bikes.assignAll(bikeList);

          if (bikeList.isNotEmpty) {
            bool activeBikeExists = bikeList.any((b) => b.bikeId == selectedBikeId.value);
            if (!activeBikeExists) {
              setAsActiveBike(bikeList.first.bikeId);
            }
          } else {
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
  Future<void> setAsActiveBike(String bikeId) async {
    if (selectedBikeId.value == bikeId) return;

    selectedBikeId.value = bikeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_bike_id', bikeId);
  }

  Future<void> _clearSavedBikeId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_bike_id');
  }



  /// Calculates the lifetime km/l average for a given bike
  double calculateKml(BikeModel bike) {
    double distance = bike.currentOdometer - bike.firstOdometer;
    if (bike.totalLiters > 0) {
      return distance / bike.totalLiters;
    }
    return 0.0;
  }

  @override
  void onClose() {
    _bikesSubscription?.cancel();
    super.onClose();
  }
}