import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mainBikeControllre/mainBike_Controllre.dart';
import '../../models/bike_model.dart';
import '../../resources/assets/image_assets.dart';
import 'AddBike/addBikeScreen.dart';
import 'bikeDetail/bikeDetailScreen.dart';



class BikesScreen extends StatelessWidget {
  const BikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the permanent controller (do not use .put here!)
    final controller = Get.find<MainBikesController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('my_garage'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.primaryColor),
            onPressed: () => Get.to(() => const AddBikeScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ==========================================
        // --- EMPTY STATE UI ---
        // ==========================================
        if (controller.bikes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.two_wheeler,
                      size: 80,
                      color: theme.primaryColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'empty_garage_title'.tr,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'empty_garage_desc'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const AddBikeScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        'add_first_bike'.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ==========================================
        // --- POPULATED LIST UI ---
        // ==========================================
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top helper text
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                child: Text(
                  'select_active_bike'.tr,
                  style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: controller.bikes.length,
                  itemBuilder: (context, index) {
                    final BikeModel bike = controller.bikes[index];

                    // Wrap EACH card in an Obx so it listens to selection changes instantly
                    return Obx(() {
                      final isActive = bike.bikeId == controller.selectedBikeId.value;

                      return _BikeCard(
                        bike: bike,
                        isActive: isActive,
                        theme: theme,
                        onCardTap: () {
                          controller.setAsActiveBike(bike.bikeId);
                        },
                        onDetailsTap: () {
                          controller.setAsActiveBike(bike.bikeId);
                          Get.to(() => const BikeDetailScreen());
                        },
                      );
                    });
                  },
                ),
              ),

              // Add Another Bike Button
              InkWell(
                onTap: () => Get.to(() => const AddBikeScreen()),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24, top: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+ ' + 'add_another_bike'.tr,
                      style: TextStyle(color: theme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// --- Internal Component: Bike Card ---
class _BikeCard extends StatelessWidget {
  final BikeModel bike;
  final bool isActive;
  final ThemeData theme;
  final VoidCallback onCardTap;
  final VoidCallback onDetailsTap;

  const _BikeCard({
    required this.bike,
    required this.isActive,
    required this.theme,
    required this.onCardTap,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    // Live Calculations
    double distance = bike.currentOdometer - bike.firstOdometer;
    double kml = bike.totalLiters > 0 ? (distance / bike.totalLiters) : 0.0;

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? theme.primaryColor : theme.dividerColor.withOpacity(0.3),
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            // Top Section (Identity)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: bike.imageUrl.isNotEmpty
                            ? NetworkImage(bike.imageUrl) as ImageProvider
                            : const AssetImage(ImageAssets.bikeCard), // Ensure this exists
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${bike.nickname} - ${bike.brand} ${bike.model}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${bike.registration} • ${bike.year}",
                          style: TextStyle(color: theme.hintColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Active Badge
                  isActive
                      ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'active'.tr.toUpperCase(),
                      style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Bottom Section (Stats & View Details Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn("${bike.currentOdometer.toInt()}", "km odo", theme),
                  _buildStatColumn(kml.toStringAsFixed(1), 'kml_average'.tr, theme, isHighlight: true),

                  // Elevated Button isolates its own tap gesture away from the card's GestureDetector
                  ElevatedButton(
                    onPressed: onDetailsTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('view_details'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primaryColor)),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, ThemeData theme, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isHighlight ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
            )
        ),
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: 11)),
      ],
    );
  }
}