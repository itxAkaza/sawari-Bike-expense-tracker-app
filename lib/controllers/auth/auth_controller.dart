import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireBaseAuthService/firbase_auth_services.dart';
import '../../resources/route/routes_names.dart';
import '../../user_prefernce/userPrefrence.dart';
import '../more/more_controller.dart'; // Make sure this path is correct

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive State variables
  final RxBool isLoginLoading = false.obs;
  final RxBool isGuestLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool hidePassword = true.obs;

  void togglePassword() {
    hidePassword.value = !hidePassword.value;
  }

  // ==========================================
  // --- HELPER: SAVE TO LOCAL STORAGE ---
  // ==========================================
  Future<void> _syncToLocalStorage(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      await UserPreference.saveUserSettings(
        isGuest: data['isGuest'] ?? true,
        userName: data['name'] ?? 'Guest',
        userEmail: data['email'] ?? '',
        theme: data['theme'] ?? 'auto',
        currency: data['currency'] ?? 'PKR - Rs.',
        petrolPrice: (data['petrolPrice'] ?? 272.5).toDouble(),
        warnDays: data['warnBeforeDays'] ?? 7,
        warnKm: data['warnBeforeKm'] ?? 100,
      );
    }
  }

  // ==========================================
  // --- LOGIN LOGIC ---
  // ==========================================
  Future<void> login() async {
    final String email = emailController.text.trim().toLowerCase();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Utils.toastMesseges('err_empty_fields'.tr);
      return;
    }

    try {
      isLoginLoading.value = true;
      final userCredential = await _authService.signinWithEmailPassword(email, password);

      // Save data locally instantly after login
      await _syncToLocalStorage(userCredential.user!.uid);

      Utils.toastMessegessuccess('success_welcome'.tr);
      Get.offAllNamed(RoutesNames.homeBottomBarScreen);

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
    } finally {
      isLoginLoading.value = false;
    }
  }

  // ==========================================
  // --- REGISTRATION LOGIC ---
  // ==========================================
  // Future<void> register() async {
  //   final String name = nameController.text.trim();
  //   final String email = emailController.text.trim().toLowerCase();
  //   final String password = passwordController.text.trim();
  //
  //   if (name.isEmpty || email.isEmpty || password.isEmpty) {
  //     Utils.toastMesseges('err_empty_fields'.tr);
  //     return;
  //   }
  //
  //   if (password.length < 6) {
  //     Utils.toastMesseges('err_password_length'.tr);
  //     return;
  //   }
  //
  //   try {
  //     isRegisterLoading.value = true;
  //     final userCredential = await _authService.signupWithEmailPassword(email, password, name);
  //
  //     // Save data locally instantly after registration
  //     await _syncToLocalStorage(userCredential.user!.uid);
  //
  //     Utils.toastMessegessuccess('success_account_created'.tr);
  //     Get.offAllNamed(RoutesNames.homeBottomBarScreen);
  //
  //   } on FirebaseAuthException catch (e) {
  //     _handleAuthError(e);
  //   } catch (e) {
  //     Utils.toastMesseges('err_default'.tr);
  //   } finally {
  //     isRegisterLoading.value = false;
  //   }
  // }

  // ==========================================
  // --- GUEST LOGIN LOGIC ---
  // ==========================================
  Future<void> continueAsGuest() async {
    try {
      isGuestLoading.value = true;
      final userCredential = await _authService.signInAnonymously();

      // Save data locally instantly after guest login
      await _syncToLocalStorage(userCredential.user!.uid);

      Utils.toastMessegessuccess('success_guest'.tr);
      Get.offAllNamed(RoutesNames.homeBottomBarScreen);

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Utils.toastMesseges('err_network'.tr);
    } finally {
      isGuestLoading.value = false;
    }
  }

  // ==========================================
  // --- REGISTRATION LOGIC ---
  // ==========================================
  Future<void> register() async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim().toLowerCase();
    final String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Utils.toastMesseges('err_empty_fields'.tr);
      return;
    }

    if (password.length < 6) {
      Utils.toastMesseges('err_password_length'.tr);
      return;
    }

    try {
      isRegisterLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      UserCredential userCredential;

      // 1. Check if we are upgrading a Guest OR making a brand new user
      if (currentUser != null && currentUser.isAnonymous) {
        // UPGRADE GUEST: Keeps the same UID, so all bikes & data remain!
        userCredential = await _authService.convertGuestToPermanent(email, password, name);
      } else {
        // STANDARD SIGNUP
        userCredential = await _authService.signupWithEmailPassword(email, password, name);
      }

      // 2. Save data locally instantly after registration
      await _syncToLocalStorage(userCredential.user!.uid);

      // 3. If the MoreController is alive, update its UI instantly
      if (Get.isRegistered<MoreController>()) {
        final moreCtrl = Get.find<MoreController>();
        moreCtrl.isGuest.value = false;
        moreCtrl.userName.value = name;
        moreCtrl.userEmail.value = email;
      }

      Utils.toastMessegessuccess('success_account_created'.tr);
      Get.offAllNamed(RoutesNames.homeBottomBarScreen);

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Utils.toastMesseges('err_default'.tr);
    } finally {
      isRegisterLoading.value = false;
    }
  }

  // ==========================================
  // --- LOCALIZED ERROR HANDLING MAPPER ---
  // ==========================================
  void _handleAuthError(FirebaseAuthException e) {
    String translationKey;
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        translationKey = 'err_invalid_credentials';
        break;
      case 'invalid-email':
        translationKey = 'err_invalid_email';
        break;
      case 'email-already-in-use':
        translationKey = 'err_email_in_use';
        break;
      case 'user-disabled':
        translationKey = 'err_disabled';
        break;
      case 'network-request-failed':
        translationKey = 'err_network';
        break;
      case 'too-many-requests':
        translationKey = 'err_too_many_requests';
        break;
      default:
        translationKey = 'err_default';
    }
    Utils.toastMesseges(translationKey.tr);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}