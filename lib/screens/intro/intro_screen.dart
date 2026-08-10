import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../controllers/language/language_controller.dart';
import '../../resources/assets/image_assets.dart';
import '../../resources/route/routes_names.dart';
import '../../services/splash_services.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controllers into memory for the first time
    final authCtrl = Get.put(AuthController());
    final langCtrl = Get.put(LanguageController());
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP BAR: Logo & Language Toggle ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.cardColor,
                      image: const DecorationImage(
                        image: AssetImage(ImageAssets.logo),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.language, color: theme.iconTheme.color),
                    onPressed: langCtrl.toggleLanguage,
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // --- MAIN GREEN CARD ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1B4E3B), theme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5-SECOND FUEL ENTRY',
                      style: TextStyle(color: Colors.greenAccent.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'intro_card_title'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'intro_card_subtitle'.tr,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 3 FEATURE CARDS ---
              Row(
                children: [
                  Expanded(child: _buildFeatureCard(theme, Icons.notifications_active_outlined, 'feature_1'.tr)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFeatureCard(theme, Icons.wifi_off_outlined, 'feature_2'.tr)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFeatureCard(theme, Icons.insights_outlined, 'feature_3'.tr)),
                ],
              ),

              const Spacer(flex: 3),

              // --- BOTTOM ACTIONS ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: authCtrl.isGuestLoading.value ? null : () async {
                    // Update Guest Login flow
                    await SplashServices.markIntroAsSeen();
                    authCtrl.continueAsGuest();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: authCtrl.isGuestLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('btn_guest'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () async {
                  await SplashServices.markIntroAsSeen();
                  Get.toNamed(RoutesNames.loginScreen);
                },
                child: Text('btn_have_account'.tr, style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () async {
                  await SplashServices.markIntroAsSeen();
                  Get.toNamed(RoutesNames.registerScreen);
                },
                child: Text('create_account_instead'.tr, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.primaryColor, size: 24),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ],
      ),
    );
  }
}