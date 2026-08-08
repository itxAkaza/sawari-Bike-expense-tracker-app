import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/more/more_controller.dart';


class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoreController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Section ---
            Obx(() => _ProfileCard(
              userName: controller.userName.value,
              userEmail: controller.userEmail.value,
              isGuest: controller.isGuest.value,
              onTap: controller.onProfileTap,
            )),
            const SizedBox(height: 24),

            // --- Appearance Section ---
            _SectionHeader(title: 'sec_appearance'.tr),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ToggleRow(
                    label: 'theme'.tr,
                    icon: Icons.wb_sunny_outlined,
                    options: ['light', 'dark', 'auto'],
                    selectedValue: controller.currentTheme,
                    onChanged: controller.updateTheme,
                  ),
                  const Divider(height: 24),
                  _ToggleRow(
                    label: 'language'.tr,
                    icon: Icons.language,
                    options: ['en', 'ur'],
                    selectedValue: controller.currentLanguage,
                    onChanged: controller.updateLanguage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Units & Currency Section ---
            _SectionHeader(title: 'sec_units'.tr),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _CurrencyDropdown(controller: controller),
                  const Divider(height: 24),
                  _PetrolPriceInput(controller: controller),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Reminders Section ---
            _SectionHeader(title: 'sec_reminders'.tr),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('notifications'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('notif_desc'.tr, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                    value: controller.notificationsEnabled.value,
                    activeColor: theme.primaryColor,
                    onChanged: controller.toggleNotifications,
                  )),
                  const Divider(height: 24),

                  Text('warn_days'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Obx(() => _ChoiceChipGroup(
                    options: const [7, 3, 1],
                    selectedValue: controller.warnDays.value,
                    suffix: 'days_suffix'.tr,
                    onSelected: controller.updateWarnDays,
                  )),
                  const SizedBox(height: 16),

                  Text('warn_dist'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Obx(() => _ChoiceChipGroup(
                    options: const [100, 50, 25],
                    selectedValue: controller.warnKm.value,
                    suffix: 'km_suffix'.tr,
                    onSelected: controller.updateWarnKm,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Logout Button ---
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text('logout'.tr, style: const TextStyle(color: Colors.red, fontSize: 16)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// ==========================================
// --- WIDGET COMPONENTS ---
// ==========================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).hintColor,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool isGuest;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.isGuest,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isGuest ? onTap : null, // Disables the ripple effect if logged in
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      userName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),

                  // Show backup prompt if guest, otherwise show email
                  if (isGuest)
                    Text(
                      'tap_to_backup'.tr,
                      style: TextStyle(color: theme.hintColor, fontSize: 12),
                    )
                  else if (userEmail.isNotEmpty)
                    Text(
                      userEmail,
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                ],
              ),
            ),

            // Only show the navigation arrow if they are a guest
            if (isGuest)
              Icon(Icons.chevron_right, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final RxString selectedValue;
  final Function(String) onChanged;

  const _ToggleRow({required this.label, required this.icon, required this.options, required this.selectedValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.hintColor),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: options.map((opt) {
              bool isSelected = selectedValue.value == opt;
              return GestureDetector(
                onTap: () => onChanged(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opt.tr, // Translates 'light', 'dark', 'en', etc.
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.hintColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final MoreController controller;
  const _CurrencyDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = ['PKR - Rs.', 'USD - \$', 'AED - د.إ', 'SAR - ريال'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('currency'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Obx(() => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.currency.value,
            icon: Icon(Icons.expand_more, color: theme.primaryColor),
            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600, fontSize: 16),
            onChanged: (String? newValue) {
              if (newValue != null) controller.updateCurrency(newValue);
            },
            items: currencies.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }
}

class _PetrolPriceInput extends StatelessWidget {
  final MoreController controller;
  const _PetrolPriceInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('petrol_price'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text('petrol_desc'.tr, style: TextStyle(color: theme.hintColor, fontSize: 11)),
          ],
        ),
        Row(
          children: [
            Obx(() => Text(controller.currency.value.split(' ')[0], style: TextStyle(color: theme.hintColor))),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              height: 35,
              child: TextField(
                controller: controller.petrolPriceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onSubmitted: controller.updatePetrolPrice,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChipGroup extends StatelessWidget {
  final List<int> options;
  final int selectedValue;
  final String suffix;
  final Function(int) onSelected;

  const _ChoiceChipGroup({required this.options, required this.selectedValue, required this.suffix, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      children: options.map((value) {
        bool isSelected = selectedValue == value;
        return ChoiceChip(
          label: Text('$value $suffix'),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected) onSelected(value);
          },
          selectedColor: theme.primaryColor.withOpacity(0.1),
          backgroundColor: theme.scaffoldBackgroundColor,
          labelStyle: TextStyle(
            color: isSelected ? theme.primaryColor : theme.hintColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? theme.primaryColor : theme.dividerColor,
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}