import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/schedule/scheduleFireStore.dart';
import '../../models/schedule_model.dart';
import '../mainBikeControllre/mainBike_Controllre.dart';
import '../../services/notifiction_service.dart';
import '../more/more_controller.dart'; // Needed for warnKm and warnDays

class ScheduleController extends GetxController {
  final ScheduleFirestoreService _dbService = ScheduleFirestoreService();
  final MainBikesController _mainController = Get.find<MainBikesController>();
  final NotificationServices _notificationService = NotificationServices();

  StreamSubscription? _scheduleSubscription;

  // --- Global State ---
  final schedules = <ScheduleModel>[].obs;
  final isLoading = false.obs;
  final isProcessingAction = false.obs;

  // Track notified schedules to prevent spam
  final Set<String> _notifiedSchedules = {};

  // --- Form State ---
  final titleController = TextEditingController();
  final repeatController = TextEditingController();
  final lastDoneController = TextEditingController();
  final isKmMode = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final initialBikeId = _mainController.selectedBikeId.value;
    if (initialBikeId != null && initialBikeId.isNotEmpty) {
      _listenToSchedules(initialBikeId);
    }

    ever(_mainController.selectedBikeId, (String? newBikeId) {
      if (newBikeId != null && newBikeId.isNotEmpty) {
        _listenToSchedules(newBikeId);
      } else {
        schedules.clear();
        _scheduleSubscription?.cancel();
      }
    });
  }

  void toggleMode(bool kmMode) {
    isKmMode.value = kmMode;
    repeatController.clear();
    lastDoneController.clear();
  }

  void _listenToSchedules(String bikeId) {
    _scheduleSubscription?.cancel();
    isLoading.value = true;

    _scheduleSubscription = _dbService.getBikeSchedulesStream(bikeId).listen(
            (data) {
          schedules.assignAll(data);
          isLoading.value = false;
          _lazyEvaluateKmSchedules(data); // <--- Triggers KM checks on every data update!
        },
        onError: (error) {
          Utils.toastMesseges('err_schedule_stream'.tr);
          isLoading.value = false;
        }
    );
  }

  // ==========================================
  // --- THE NOTIFICATION ENGINE ---
  // ==========================================

  // 1. LAZY EVALUATION (For KM)
  void _lazyEvaluateKmSchedules(List<ScheduleModel> data) {
    final bike = _mainController.activeBike;
    if (bike == null || !Get.isRegistered<MoreController>()) return;

    final warnKm = Get.find<MoreController>().warnKm.value;

    for (var schedule in data) {
      if (schedule.type == 'km') {
        double diff = (schedule.target as double) - bike.currentOdometer;

        if (diff <= warnKm && !_notifiedSchedules.contains(schedule.scheduleId)) {
          _notifiedSchedules.add(schedule.scheduleId);

          if (diff > 0) {
            _notificationService.showNotification(
              id: schedule.scheduleId.hashCode,
              title: 'Maintenance Due Soon',
              body: '${schedule.title} is due in ${diff.toInt()} km for ${bike.nickname}!',
            );
          } else {
            _notificationService.showNotification(
              id: schedule.scheduleId.hashCode,
              title: 'Maintenance Overdue!',
              body: '${schedule.title} is overdue by ${diff.abs().toInt()} km!',
            );
          }
        }
      }
    }
  }

  // 2. OS ALARM SCHEDULING (For Dates)
  Future<void> _scheduleDateAlarm(String scheduleId, String title, DateTime targetDate) async {
    if (!Get.isRegistered<MoreController>()) return;

    final warnDays = Get.find<MoreController>().warnDays.value;
    DateTime alarmDate = targetDate.subtract(Duration(days: warnDays));

    // Only schedule if the alarm date is in the future
    if (alarmDate.isAfter(DateTime.now())) {
      await _notificationService.showScheduleNotification(
        id: scheduleId.hashCode,
        title: 'Upcoming Maintenance',
        body: '$title is due in $warnDays days!',
        scheduledDate: alarmDate,
      );
    }
  }


  // ==========================================
  // --- CORE ACTIONS ---
  // ==========================================

  Future<void> saveNewSchedule() async {
    final bike = _mainController.activeBike;
    if (bike == null) return;

    final title = titleController.text.trim();
    final double? repeat = double.tryParse(repeatController.text.trim());
    final double? lastDone = double.tryParse(lastDoneController.text.trim());

    if (title.isEmpty || repeat == null || lastDone == null) {
      Utils.toastMesseges('err_empty_fields'.tr);
      return;
    }

    // ==========================================
    // --- THE NEW BUG FIX: LOGICAL VALIDATION ---
    // ==========================================
    if (isKmMode.value && lastDone > bike.currentOdometer) {
      Utils.toastMesseges('err_last_done_high'.tr);
      return; // Stop the save process!
    }

    try {
      isSaving.value = true;
      dynamic target;
      dynamic finalLastDone;
      DateTime? targetDateObj;

      if (isKmMode.value) {
        finalLastDone = lastDone;
        target = lastDone + repeat;
      } else {
        DateTime now = DateTime.now();
        DateTime lastDoneDate = now.subtract(Duration(days: lastDone.toInt()));
        finalLastDone = Timestamp.fromDate(lastDoneDate);

        targetDateObj = DateTime(lastDoneDate.year, lastDoneDate.month + repeat.toInt(), lastDoneDate.day);
        target = Timestamp.fromDate(targetDateObj);
      }

      final scheduleData = {
        'title': title,
        'type': isKmMode.value ? 'km' : 'date',
        'target': target,
        'repeat': repeat,
        'lastDone': finalLastDone,
      };

      final docRef = FirebaseFirestore.instance.collection('bikes').doc(bike.bikeId).collection('schedules').doc();
      scheduleData['scheduleId'] = docRef.id;
      await docRef.set(scheduleData);

      // --- ACTIVATE OS ALARM FOR DATES ---
      if (!isKmMode.value && targetDateObj != null) {
        await _scheduleDateAlarm(docRef.id, title, targetDateObj);
      }

      Utils.toastMessegessuccess('success_bike_added'.tr);
      Get.back();

      titleController.clear();
      repeatController.clear();
      lastDoneController.clear();
    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> markAsDone(ScheduleModel schedule, String costStr, String odoStr) async {
    final bike = _mainController.activeBike;
    if (bike == null) return;

    if (costStr.isEmpty || odoStr.isEmpty) {
      Utils.toastMesseges('err_empty_fields'.tr);
      return;
    }

    final double cost = double.tryParse(costStr) ?? 0.0;
    final double? parsedOdo = double.tryParse(odoStr);

    if (parsedOdo == null || parsedOdo < bike.currentOdometer) {
      Utils.toastMesseges('err_odo_low'.tr);
      return;
    }

    try {
      isProcessingAction.value = true;
      Get.back();

      await _dbService.markScheduleDoneBatch(
        bikeId: bike.bikeId,
        schedule: schedule,
        cost: cost,
        newOdometer: parsedOdo,
        masterCurrentOdo: bike.currentOdometer,
        masterTotalMaintenance: bike.totalMaintenanceSpend,
        now: DateTime.now(),
      );

      // --- RE-ARM OS ALARM FOR DATES ---
      if (schedule.type == 'date') {
        DateTime now = DateTime.now();
        DateTime nextDate = DateTime(now.year, now.month + schedule.repeat.toInt(), now.day);
        await _scheduleDateAlarm(schedule.scheduleId, schedule.title, nextDate);
      } else {
        // Clear it from the notified list so KM lazy evaluation can alert again next time
        _notifiedSchedules.remove(schedule.scheduleId);
      }

      Utils.toastMessegessuccess('success_maintenance'.tr);
    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
    } finally {
      isProcessingAction.value = false;
    }
  }

  Future<void> cancelSchedule(String scheduleId) async {
    final bikeId = _mainController.selectedBikeId.value;
    if (bikeId == null) return;
    try {
      await _dbService.deleteSchedule(bikeId, scheduleId);

      // Cancel the OS alarm so it doesn't ring for a deleted schedule!
      await _notificationService.cancelNotification(scheduleId.hashCode);

      Utils.toastMessegessuccess('success_deleted'.tr);
    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
    }
  }

  @override
  void onClose() {
    _scheduleSubscription?.cancel();
    super.onClose();
  }
}