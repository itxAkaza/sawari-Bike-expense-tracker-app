import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/MyButton.dart';
import '../../components/MyTextFormfield.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/language/language_controller.dart';
import '../../resources/assets/image_assets.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
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
              // --- Smaller Logo for Register Screen ---
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                  image: const DecorationImage(
                    image: AssetImage(ImageAssets.logo),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'register'.tr,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.04),

              // --- Input Fields ---
              MyTextFormField(
                hintText: 'full_name',
                controller: authController.nameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 16),

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

              SizedBox(height: size.height * 0.05),

              // --- Action Buttons ---
              Obx(() => MyButton(
                text: 'register',
                isLoading: authController.isRegisterLoading.value,
                onTap: authController.register,
              )),

              SizedBox(height: size.height * 0.04),

              // --- Navigation to Login ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'have_account'.tr,
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'login_now'.tr,
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