import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/homeBottomBar/home_bottomBar_controller.dart';


class HomeBottomBarScreen extends StatelessWidget {
  const HomeBottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainHomeViewModel());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Obx(() => controller.screens[controller.viewIndex.value]),

      // Custom Pure Flutter Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: size.height * 0.09, // Responsive height
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_outlined,
                    label: 'nav_home'.tr,
                    index: 0,
                    currentIndex: controller.viewIndex.value,
                    onTap: () => controller.setIndex(0),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.access_time,
                    label: 'nav_history'.tr,
                    index: 1,
                    currentIndex: controller.viewIndex.value,
                    onTap: () => controller.setIndex(1),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.notifications_none,
                    label: 'nav_alerts'.tr,
                    index: 2,
                    currentIndex: controller.viewIndex.value,
                    onTap: () => controller.setIndex(2),

                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.pedal_bike, // Closest default icon to your design
                    label: 'nav_bikes'.tr,
                    index: 3,
                    currentIndex: controller.viewIndex.value,
                    onTap: () => controller.setIndex(3),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.light_mode_outlined,
                    label: 'nav_more'.tr,
                    index: 4,
                    currentIndex: controller.viewIndex.value,
                    onTap: () => controller.setIndex(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Extracted widget for individual navigation items to keep code clean
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final isSelected = index == currentIndex;

    final color = isSelected
        ? theme.primaryColor
        : theme.bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(), // Matching your image capitalization
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}