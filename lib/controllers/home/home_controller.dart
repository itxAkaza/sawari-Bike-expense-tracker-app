import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/home/homeFireStore.dart';
import '../mainBikeControllre/mainBike_Controllre.dart';
import '../more/more_controller.dart';


class HomeController extends GetxController {
  final MainBikesController _mainCtrl = Get.find<MainBikesController>();
  final MoreController _moreCtrl = Get.find<MoreController>();
  final HomeFirestoreService _dbService = HomeFirestoreService();

  // Controllers for Bottom Sheets
  final amountController = TextEditingController();
  final odoController = TextEditingController();

  final isSaving = false.obs;

  // Predefined Categories
  final List<String> expenseCategories = ['oil_change', 'tuning', 'tyre_tube', 'battery', 'tax_insur'];
  final List<String> repairCategories = ['puncture', 'electrical', 'brake_work', 'accident_repair', 'other'];

  var selectedCategory = ''.obs;

  void openBottomSheet(String type) {
    amountController.clear();
    selectedCategory.value = type == 'maintenance' ? expenseCategories[0] : repairCategories[0];

    // Pre-fill odometer safely
    final bike = _mainCtrl.activeBike;
    if (bike != null) {
      odoController.text = bike.currentOdometer.toInt().toString();
    }
  }

  void setQuickAmount(String amount) {
    amountController.text = amount;
  }

  Future<void> submitEntry(String type) async {
    final bike = _mainCtrl.activeBike;
    if (bike == null) return;

    final String amountStr = amountController.text.trim();
    final String odoStr = odoController.text.trim();

    if (amountStr.isEmpty || odoStr.isEmpty) {
      Utils.toastMesseges('err_empty_fields'.tr);
      return;
    }

    final double amount = double.tryParse(amountStr) ?? 0.0;
    final double newOdo = double.tryParse(odoStr) ?? 0.0;

    // VALIDATION STRICTLY AS REQUESTED
    if (type == 'fuel' && newOdo <= bike.currentOdometer) {
      Utils.toastMesseges('err_fuel_odo_low'.tr);
      return;
    } else if (newOdo < bike.currentOdometer) {
      Utils.toastMesseges('err_odo_low'.tr);
      return;
    }

    try {
      isSaving.value = true;
      double? liters;
      String category = 'Petrol'; // Default for fuel

      if (type == 'fuel') {
        liters = amount / _moreCtrl.petrolPrice.value;
      } else {
        category = selectedCategory.value.tr; // Use the translated chip name
      }

      final logData = {
        'type': type,
        'category': category,
        'amount': amount,
        'odometer': newOdo,
        'liters': liters,
        'isOneTimeRepair': type == 'repair',
        'note': '',
        'datetime': FieldValue.serverTimestamp(),
      };

      await _dbService.addLogAndUpdateBikeBatch(
        bikeId: bike.bikeId,
        logData: logData,
        amount: amount,
        newOdometer: newOdo,
        liters: liters,
        type: type,
      );

      Utils.toastMessegessuccess('success_maintenance'.tr);
      Get.back(); // Close bottom sheet

    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    odoController.dispose();
    super.onClose();
  }
}