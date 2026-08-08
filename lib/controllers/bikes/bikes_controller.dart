import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/bikes/bikesFireStoreService.dart';
import '../../services/cloudinary_services.dart';



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

  // --- Loading State ---
  var isSaving = false.obs;

  // Predefined lists for UI chips
  final List<String> brands = ['Honda', 'Yamaha', 'Suzuki', 'United', 'Road Prince', 'Other'];
  final List<String> models = ['CD 70', 'CG 125', 'CB 150F', 'YBR 125', 'GS 150'];

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

    // Check if it's a valid number, older than 1900, or from the future
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
      String? imageUrl;

      // 2. Upload Image with dedicated exception handling
      // 2. Upload Image with dedicated exception handling
      if (selectedImageFile.value != null) {
        try {
          imageUrl = await _cloudinaryService.uploadImage(selectedImageFile.value!);
          if (imageUrl == null) {
            Utils.toastMesseges('err_image_upload_failed'.tr);
            isSaving.value = false;
            return;
          }
        } catch (e) {
          // Check the exact exception message thrown by CloudinaryService
          if (e.toString().contains("network_error")) {
            Utils.toastMesseges('err_image_upload_network'.tr);
          } else {
            Utils.toastMesseges('err_image_upload_failed'.tr);
          }
          isSaving.value = false;
          return;
        }
      }

      // 3. Construct Data Payload based on Schema
      final bikeData = {
        'userId': uid, // <--- ADD THIS LINE! This links the bike to the user.
        'brand': selectedBrand.value,
        'model': selectedModel.value,
        'nickname': nicknameController.text.trim(),
        'year': yearController.text.trim(),
        'registration': registrationController.text.trim().toUpperCase(),
        'currentOdometer': currentOdo,
        'firstOdometer': currentOdo,
        'imageUrl': imageUrl ?? '',
        'totalFuelSpend': 0,
        'totalMaintenanceSpend': 0,
        'totalRepairSpend': 0,
        'totalLiters': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 4. Save to Firestore
      await _firestoreService.addBike(bikeData);

      Utils.toastMessegessuccess('success_bike_added'.tr);
      Get.back(); // Return to previous screen

    } on FirebaseException catch (e) {
      _handleFirestoreError(e);
    } catch (e) {
      Utils.toastMesseges('err_save_bike'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  // ==========================================
  // --- LOCALIZED ERROR HANDLING MAPPER ---
  // ==========================================
  void _handleFirestoreError(FirebaseException e) {
    String translationKey;
    switch (e.code) {
      case 'permission-denied':
        translationKey = 'err_permission_denied';
        break;
      case 'unavailable':
      case 'network-request-failed':
        translationKey = 'err_network'; // Reusing your existing network error key
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