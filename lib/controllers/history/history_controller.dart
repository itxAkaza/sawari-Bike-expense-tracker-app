import 'dart:async';
import 'package:get/get.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/history/historyFireStore.dart';
import '../../models/history_model.dart';
import '../mainBikeCOntrollre/mainBike_Controllre.dart';

// import 'history_firestore_service.dart';
// import 'history_log_model.dart';
// import 'main_bikes_controller.dart';
// import '../../Utiles/utiles.dart';

class HistoryController extends GetxController {
  final HistoryFirestoreService _dbService = HistoryFirestoreService();

  // Inject the Master Controller to watch the active bike
  final MainBikesController _mainController = Get.find<MainBikesController>();

  StreamSubscription? _historySubscription;

  // --- Global State ---
  final historyLogs = <HistoryLogModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 1. If a bike is already selected when this controller boots up, load its history
    final initialBikeId = _mainController.selectedBikeId.value;
    if (initialBikeId != null && initialBikeId.isNotEmpty) {
      _listenToHistory(initialBikeId);
    }

    // 2. The GetX Magic: Watch for any future bike switches!
    ever(_mainController.selectedBikeId, (String? newBikeId) {
      if (newBikeId != null && newBikeId.isNotEmpty) {
        _listenToHistory(newBikeId);
      } else {
        // If the user deleted all their bikes, clear the list and stop listening
        historyLogs.clear();
        _historySubscription?.cancel();
      }
    });
  }

  void _listenToHistory(String bikeId) {
    // CRITICAL: Always cancel the old listener before starting a new one
    // otherwise the app will try to listen to 2 bikes at the same time!
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

  @override
  void onClose() {
    _historySubscription?.cancel();
    super.onClose();
  }
}