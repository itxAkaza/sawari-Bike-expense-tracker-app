import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/MyButton.dart';
import '../../components/MyTextFormfield.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/language/language_controller.dart';
import '../../resources/assets/image_assets.dart';
import '../../resources/route/routes_names.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controllers
    // Use Get.put() to initialize them into memory
    final authController = Get.put(AuthController());
    final languageController = Get.put(LanguageController());
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: languageController.toggleLanguage,
            tooltip: 'change_language'.tr,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),

              // --- App Logo (Circular) ---
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                  image: const DecorationImage(
                    image: AssetImage(ImageAssets.logo),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- App Branding ---
              Text(
                'app_name'.tr,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'app_tagline'.tr,
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // --- Input Fields ---
              MyTextFormField(
                hintText: 'email',
                controller: authController.emailController,
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              Obx(() => MyTextFormField(
                hintText: 'password',
                controller: authController.passwordController,
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: authController.hidePassword.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.hidePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: authController.togglePassword,
                ),
              )),

              // --- Forgot Password ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // To be implemented later
                  child: Text(
                    'forgot_password'.tr,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // --- Action Buttons ---
              Obx(() => MyButton(
                text: 'login',
                isLoading: authController.isLoginLoading.value,
                onTap: authController.login,
              )),
              const SizedBox(height: 12),

              Obx(() => MyButton(
                text: 'continue_guest',
                isGhost: true,
                isLoading: authController.isGuestLoading.value,
                onTap: authController.continueAsGuest,
              )),

              SizedBox(height: size.height * 0.04),

              // --- Navigation to Register ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'no_account'.tr,
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(RoutesNames.registerScreen),
                    child: Text(
                      'register_now'.tr,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}