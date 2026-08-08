import 'dart:async';
import 'package:get/get.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/schedule/scheduleFireStore.dart';
import '../../models/schedule_model.dart';
import '../mainBikeCOntrollre/mainBike_Controllre.dart';

// import 'schedule_firestore_service.dart';
// import 'schedule_model.dart';
// import 'main_bikes_controller.dart';
// import '../../Utiles/utiles.dart';

class ScheduleController extends GetxController {
  final ScheduleFirestoreService _dbService = ScheduleFirestoreService();

  // Inject the Master Controller to watch the active bike
  final MainBikesController _mainController = Get.find<MainBikesController>();

  StreamSubscription? _scheduleSubscription;

  // --- Global State ---
  final schedules = <ScheduleModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Load schedules if a bike is already selected on boot
    final initialBikeId = _mainController.selectedBikeId.value;
    if (initialBikeId != null && initialBikeId.isNotEmpty) {
      _listenToSchedules(initialBikeId);
    }

    // 2. Watch for bike switches and update the stream instantly
    ever(_mainController.selectedBikeId, (String? newBikeId) {
      if (newBikeId != null && newBikeId.isNotEmpty) {
        _listenToSchedules(newBikeId);
      } else {
        // Clear data if the user deletes their active bike
        schedules.clear();
        _scheduleSubscription?.cancel();
      }
    });
  }

  void _listenToSchedules(String bikeId) {
    // Kill the old listener before attaching a new one
    _scheduleSubscription?.cancel();

    isLoading.value = true;

    _scheduleSubscription = _dbService.getBikeSchedulesStream(bikeId).listen(
            (data) {
          schedules.assignAll(data);
          isLoading.value = false;
        },
        onError: (error) {
          Utils.toastMesseges('err_schedule_stream'.tr);
          isLoading.value = false;
        }
    );
  }

  @override
  void onClose() {
    _scheduleSubscription?.cancel();
    super.onClose();
  }
}