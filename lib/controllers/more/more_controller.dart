import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_settings/app_settings.dart';

import '../../Utiles/utiles.dart';
import '../../data/fireStoreDB/more/moreFireStoreService.dart';
import '../../resources/route/routes_names.dart';
import '../../services/notifiction_service.dart';
import '../../user_prefernce/userPrefrence.dart';



class MoreController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  final NotificationServices notificationService = NotificationServices();
  final MoreFirestoreService _firestoreService = MoreFirestoreService();

  // Reactive State
  var isGuest = true.obs;
  var userName = 'Guest'.obs;
  var userEmail = ''.obs;
  var currentTheme = 'auto'.obs;
  var currentLanguage = 'en'.obs;
  var currency = 'PKR - Rs.'.obs;
  var petrolPrice = 272.5.obs;

  var notificationsEnabled = true.obs;
  var warnDays = 7.obs;
  var warnKm = 100.obs;

  final TextEditingController petrolPriceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadLocalPreferences();
  }

  Future<void> _loadLocalPreferences() async {
    final prefs = await UserPreference.getUserSettings();
    isGuest.value = prefs['isGuest'];
    userName.value = prefs['userName'];
    userEmail.value = prefs['userEmail'] ?? '';
    currentTheme.value = prefs['theme'];
    currentLanguage.value = prefs['language'];
    currency.value = prefs['currency'];
    petrolPrice.value = prefs['petrolPrice'];
    notificationsEnabled.value = prefs['notificationsEnabled'];
    warnDays.value = prefs['warnDays'];
    warnKm.value = prefs['warnKm'];

    petrolPriceController.text = petrolPrice.value.toString();

    // ==========================================
    // --- THE FAIL-SAFE CHECK ---
    // ==========================================
    final user = _auth.currentUser;

    // Check if Firebase says they are a real logged-in user (not anonymous)
    if (user != null && !user.isAnonymous) {

      // If local storage wrongly thinks they are a guest or is missing data
      if (isGuest.value == true || userName.value == 'Guest' || userEmail.value.isEmpty) {

        // 1. Force the UI out of Guest mode immediately
        isGuest.value = false;
        userEmail.value = user.email ?? '';

        // 2. Fetch their real name from Firestore
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            userName.value = doc.data()!['name'] ?? 'User';

            // 3. Fix their corrupted Local Storage silently
            await UserPreference.saveUserSettings(
              isGuest: false,
              userName: userName.value,
              userEmail: userEmail.value,
              theme: currentTheme.value,
              language: currentLanguage.value,
              currency: currency.value,
              petrolPrice: petrolPrice.value,
              notifications: notificationsEnabled.value,
              warnDays: warnDays.value,
              warnKm: warnKm.value,
            );
          }
        } catch (e) {
          // Silent catch for background fail-safe
        }
      }
    }
  }

  void toggleNotifications(bool value) async {
    if (value) {
      bool osPermissionGranted = await notificationService.requestAndCheckPermissions();

      if (osPermissionGranted) {
        notificationsEnabled.value = true;
        UserPreference.updateSetting('notifications_enabled', true);
        _firestoreService.syncUserSettings({'notificationsEnabled': true});
        await notificationService.initNotification(true);
      } else {
        notificationsEnabled.value = false;
        Utils.toastMesseges('err_notif_permission'.tr);
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
    } else {
      notificationsEnabled.value = false;
      UserPreference.updateSetting('notifications_enabled', false);
      _firestoreService.syncUserSettings({'notificationsEnabled': false});
      await notificationService.cancelAllNotifications();
    }
  }

  void updateTheme(String theme) {
    currentTheme.value = theme;
    UserPreference.updateTheme(theme);
    if (theme == 'light') Get.changeThemeMode(ThemeMode.light);
    else if (theme == 'dark') Get.changeThemeMode(ThemeMode.dark);
    else Get.changeThemeMode(ThemeMode.system);
    _firestoreService.syncUserSettings({'theme': theme});
  }

  void updateLanguage(String lang) {
    currentLanguage.value = lang;
    UserPreference.updateLanguage(lang);
    Get.updateLocale(lang == 'ur' ? const Locale('ur', 'PK') : const Locale('en', 'US'));
  }

  void updateCurrency(String newCurrency) {
    currency.value = newCurrency;
    UserPreference.updateSetting('app_currency', newCurrency);
    _firestoreService.syncUserSettings({'currency': newCurrency});
  }

  void updatePetrolPrice(String priceStr) {
    double? price = double.tryParse(priceStr);
    if (price != null) {
      petrolPrice.value = price;
      UserPreference.updateSetting('petrol_price', price);
      _firestoreService.syncUserSettings({'petrolPrice': price});
    }
  }

  void updateWarnDays(int days) {
    warnDays.value = days;
    UserPreference.updateSetting('warn_days', days);
    _firestoreService.syncUserSettings({'warnBeforeDays': days});
  }

  void updateWarnKm(int km) {
    warnKm.value = km;
    UserPreference.updateSetting('warn_km', km);
    _firestoreService.syncUserSettings({'warnBeforeKm': km});
  }

  void onProfileTap() {
    if (isGuest.value) {
      Get.toNamed(RoutesNames.registerScreen);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await UserPreference.clearUserData();
    Get.offAllNamed(RoutesNames.loginScreen);
  }
}