import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../../controllers/bikes/bikes_controller.dart';


class AddBikeScreen extends StatelessWidget {
  const AddBikeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BikeController());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                ]
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('add_your_bike'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Picker ---
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: controller.pickImage,
                      child: Obx(() {
                        final File? file = controller.selectedImageFile.value;
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: theme.primaryColor.withOpacity(0.5),
                                width: 2,
                                style: BorderStyle.solid // Consider dashed package later if needed
                            ),
                            image: file != null
                                ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                                : null,
                          ),
                          child: file == null
                              ? Icon(Icons.camera_alt_outlined, color: theme.primaryColor, size: 32)
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text('add_photo_opt'.tr, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Brand Selection ---
              _buildSectionTitle('brand'.tr, theme),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.brands.map((brand) => _buildChoiceChip(
                  label: brand,
                  isSelected: controller.selectedBrand.value == brand,
                  onSelected: (val) { if (val) controller.selectedBrand.value = brand; },
                  theme: theme,
                )).toList(),
              )),
              const SizedBox(height: 24),

              // --- Model Selection ---
              _buildSectionTitle('model'.tr, theme),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.models.map((model) => _buildChoiceChip(
                  label: model,
                  isSelected: controller.selectedModel.value == model,
                  onSelected: (val) { if (val) controller.selectedModel.value = model; },
                  theme: theme,
                )).toList(),
              )),
              const SizedBox(height: 24),

              // --- Inputs: Nickname & Year ---
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInputField(
                      controller: controller.nicknameController,
                      label: 'nickname'.tr,
                      hint: 'eg_kaali'.tr,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildInputField(
                      controller: controller.yearController,
                      label: 'year'.tr,
                      hint: '2022',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Blocks minus signs and decimals
                      maxLength: 4, // Stops them at 4 digits
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Input: Registration ---
              _buildInputField(
                controller: controller.registrationController,
                label: 'registration'.tr,
                hint: 'LEB-9284',
                theme: theme,
              ),
              const SizedBox(height: 16),

              // --- Input: Odometer ---
              _buildInputField(
                controller: controller.odometerController,
                label: 'current_odometer'.tr,
                hint: '45350',
                keyboardType: TextInputType.number,
                theme: theme,
              ),
              const SizedBox(height: 12),

              Center(
                child: Text('odo_disclaimer'.tr, style: TextStyle(color: theme.hintColor, fontSize: 11)),
              ),

              SizedBox(height: size.height * 0.05),

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : controller.saveBike,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isSaving.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'save_bike_chalo'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.hintColor),
    );
  }

  Widget _buildChoiceChip({required String label, required bool isSelected, required Function(bool) onSelected, required ThemeData theme}) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: theme.primaryColor.withOpacity(0.1),
      backgroundColor: theme.scaffoldBackgroundColor,
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : theme.hintColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? theme.primaryColor : theme.dividerColor),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // Added this
    int? maxLength, // Added this
    required ThemeData theme
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label, theme),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters, // Applied here
          maxLength: maxLength, // Applied here
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, // Hides the 0/4 counter text
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

}