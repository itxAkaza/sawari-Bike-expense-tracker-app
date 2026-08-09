import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/bikes/bikesFireStoreService.dart';
import '../../services/cloudinary_services.dart';
// import '../../models/bike_model.dart'; // Ensure BikeModel is imported

class BikeController extends GetxController {
  final BikeFirestoreService _firestoreService = BikeFirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  // --- Form State ---
  var selectedBrand = 'Honda'.obs;
  var selectedModel = 'CG 125'.obs;

  final nicknameController = TextEditingController();
  final yearController = TextEditingController();
  final registrationController = TextEditingController();
  final odometerController = TextEditingController();

  // --- Image State ---
  var selectedImageFile = Rx<File?>(null);
  String? existingImageUrl; // Stores the image URL if we are editing

  // --- Edit Mode State ---
  var isEditMode = false.obs;
  String? editBikeId;

  // --- Loading State ---
  var isSaving = false.obs;

  final List<String> brands = ['Honda', 'Yamaha', 'Suzuki', 'United', 'Road Prince', 'Other'];
  final List<String> models = ['CD 70', 'CG 125', 'CB 150F', 'YBR 125', 'GS 150'];

  @override
  void onInit() {
    super.onInit();
    _checkForEditData();
  }

  void _checkForEditData() {
    if (Get.arguments != null && Get.arguments['isEdit'] == true) {
      isEditMode.value = true;
      final bike = Get.arguments['bike']; // Expects BikeModel

      editBikeId = bike.bikeId;
      existingImageUrl = bike.imageUrl;

      selectedBrand.value = bike.brand;
      selectedModel.value = bike.model;
      nicknameController.text = bike.nickname;
      yearController.text = bike.year;
      registrationController.text = bike.registration;
      odometerController.text = bike.currentOdometer.toInt().toString();
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        selectedImageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Utils.toastMesseges('err_image_pick'.tr);
    }
  }

  Future<void> saveBike() async {
    final String yearStr = yearController.text.trim();
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 1. Validation
    if (nicknameController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        registrationController.text.trim().isEmpty ||
        odometerController.text.trim().isEmpty) {
      Utils.toastMesseges('err_empty_fields'.tr);
      return;
    }

    final int? year = int.tryParse(yearStr);
    final int currentYear = DateTime.now().year;

    if (year == null || year < 1900 || year > currentYear + 1) {
      Utils.toastMesseges('err_invalid_year'.tr);
      return;
    }

    final double? currentOdo = double.tryParse(odometerController.text.trim());
    if (currentOdo == null || currentOdo < 0) {
      Utils.toastMesseges('err_invalid_odo'.tr);
      return;
    }

    try {
      isSaving.value = true;
      String? finalImageUrl = existingImageUrl;

      // 2. Upload Image
      if (selectedImageFile.value != null) {
        try {
          finalImageUrl = await _cloudinaryService.uploadImage(selectedImageFile.value!);
          if (finalImageUrl == null) {
            Utils.toastMesseges('err_image_upload_failed'.tr);
            isSaving.value = false;
            return;
          }
        } catch (e) {
          if (e.toString().contains("network_error")) {
            Utils.toastMesseges('err_image_upload_network'.tr);
          } else {
            Utils.toastMesseges('err_image_upload_failed'.tr);
          }
          isSaving.value = false;
          return;
        }
      }

      // 3. Save or Update logic
      if (isEditMode.value && editBikeId != null) {
        // UPDATE EXISTING BIKE
        // Note: We only update fields they can change. We don't overwrite spend totals.
        final updateData = {
          'brand': selectedBrand.value,
          'model': selectedModel.value,
          'nickname': nicknameController.text.trim(),
          'year': yearController.text.trim(),
          'registration': registrationController.text.trim().toUpperCase(),
          'currentOdometer': currentOdo,
          'imageUrl': finalImageUrl ?? '',
        };
        await _firestoreService.updateBike(editBikeId!, updateData);
        Utils.toastMessegessuccess('success_bike_updated'.tr);
      } else {
        // ADD NEW BIKE
        final bikeData = {
          'userId': uid,
          'brand': selectedBrand.value,
          'model': selectedModel.value,
          'nickname': nicknameController.text.trim(),
          'year': yearController.text.trim(),
          'registration': registrationController.text.trim().toUpperCase(),
          'currentOdometer': currentOdo,
          'firstOdometer': currentOdo,
          'imageUrl': finalImageUrl ?? '',
          'totalFuelSpend': 0,
          'totalMaintenanceSpend': 0,
          'totalRepairSpend': 0,
          'totalLiters': 0,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestoreService.addBike(bikeData);
        Utils.toastMessegessuccess('success_bike_added'.tr);
      }

      Get.back(); // Return to previous screen

    } on FirebaseException catch (e) {
      _handleFirestoreError(e);
    } catch (e) {
      Utils.toastMesseges('err_save_bike'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  void _handleFirestoreError(FirebaseException e) {
    String translationKey;
    switch (e.code) {
      case 'permission-denied':
        translationKey = 'err_permission_denied';
        break;
      case 'unavailable':
      case 'network-request-failed':
        translationKey = 'err_network';
        break;
      case 'deadline-exceeded':
        translationKey = 'err_timeout';
        break;
      default:
        translationKey = 'err_save_bike';
    }
    Utils.toastMesseges(translationKey.tr);
  }

  @override
  void onClose() {
    nicknameController.dispose();
    yearController.dispose();
    registrationController.dispose();
    odometerController.dispose();
    super.onClose();
  }
}