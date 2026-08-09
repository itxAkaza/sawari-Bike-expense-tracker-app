import 'dart:async';
import 'package:get/get.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/history/historyFireStore.dart';
import '../../models/history_model.dart';
import '../mainBikeControllre/mainBike_Controllre.dart';


// import 'history_firestore_service.dart';
// import 'history_log_model.dart';
// import 'main_bikes_controller.dart';
// import '../../Utiles/utiles.dart';

class HistoryController extends GetxController {
  final HistoryFirestoreService _dbService = HistoryFirestoreService();
  final MainBikesController _mainController = Get.find<MainBikesController>();

  StreamSubscription? _historySubscription;

  // --- Global State ---
  final historyLogs = <HistoryLogModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final initialBikeId = _mainController.selectedBikeId.value;
    if (initialBikeId != null && initialBikeId.isNotEmpty) {
      _listenToHistory(initialBikeId);
    }

    ever(_mainController.selectedBikeId, (String? newBikeId) {
      if (newBikeId != null && newBikeId.isNotEmpty) {
        _listenToHistory(newBikeId);
      } else {
        historyLogs.clear();
        _historySubscription?.cancel();
      }
    });
  }

  void _listenToHistory(String bikeId) {
    _historySubscription?.cancel();
    isLoading.value = true;

    _historySubscription = _dbService.getBikeHistoryStream(bikeId).listen(
            (logs) {
          historyLogs.assignAll(logs);
          isLoading.value = false;
        },
        onError: (error) {
          Utils.toastMesseges('err_history_stream'.tr);
          isLoading.value = false;
        }
    );
  }

  // --- Calculations ---

  /// Sums up all expenses (fuel, maintenance, repair) for the given year
  double calculateYearlySpend(int year) {
    double total = 0.0;
    for (var log in historyLogs) {
      if (log.datetime?.year == year) {
        total += log.amount;
      }
    }
    return total;
  }

  /// Counts the total number of maintenance and repair logs
  int calculateServiceCount() {
    int count = 0;
    for (var log in historyLogs) {
      if (log.type == 'maintenance' || log.type == 'repair') {
        count++;
      }
    }
    return count;
  }

  @override
  void onClose() {
    _historySubscription?.cancel();
    super.onClose();
  }
}