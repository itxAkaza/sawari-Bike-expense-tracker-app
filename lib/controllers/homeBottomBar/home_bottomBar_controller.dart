import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/alerts/alertScreen.dart';
import '../../screens/bikes/bikesScreen.dart';
import '../../screens/history/historyScreen.dart';
import '../../screens/home/homeScreen.dart';
import '../../screens/more/moreScreen.dart';
import '../../services/notifiction_service.dart';
import '../../user_prefernce/userPrefrence.dart';
import '../history/history_controller.dart';
import '../mainBikeCOntrollre/mainBike_Controllre.dart';
import '../more/more_controller.dart';
import '../schedule/schedule_controller.dart';


class MainHomeViewModel extends GetxController {
  // Current Tab Index
  RxInt viewIndex = 0.obs;


  @override
  void onInit() {
    super.onInit();
    // 1. Inject Global User Settings (Currency, Theme, Notifications)
    Get.put(MoreController(), permanent: true);
    // 2. Inject the Master Garage Hub (Fetches the bikes list)
    Get.put(MainBikesController(), permanent: true);
    // 3. Inject the Sub-Controllers (These instantly start listening to the Master Hub)
    Get.put(HistoryController(), permanent: true);

    Get.put(ScheduleController(), permanent: true);
    _checkInitialNotificationPermission();
  }

  // --- Initial Permission Request ---
  Future<void> _checkInitialNotificationPermission() async {
    // 1. Check what the user's local settings say
    final prefs = await UserPreference.getUserSettings();
    bool wantsNotifications = prefs['notificationsEnabled'] ?? true;

    // 2. If they want notifications, ask the OS for permission
    if (wantsNotifications) {
      bool osGranted = await NotificationServices().requestAndCheckPermissions();

      // 3. If the user clicks "Deny" on the OS popup, we must sync that back to our app
      if (!osGranted) {
        // This ensures the toggle in MoreScreen will accurately show as OFF
        await UserPreference.updateSetting('notifications_enabled', false);
      }
    }
  }

  // The 5 Main Screens
  final List<Widget> screens = const [
    HomeScreen(),
    HistoryScreen(),
    AlertScreen(),
    BikesScreen(),
    MoreScreen(),
  ];

  void setIndex(int index) {
    viewIndex.value = index;
  }
}