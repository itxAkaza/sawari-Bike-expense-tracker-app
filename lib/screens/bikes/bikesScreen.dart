import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mainBikeCOntrollre/mainBike_Controllre.dart';
import 'AddBike/addBikeScreen.dart';
import 'bikeDetail/bikeDetailScreen.dart';

class BikesScreen extends StatelessWidget {
  const BikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep main controller alive to listen to stream continuously
    final controller = Get.put(MainBikesController(), permanent: true);
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top helper text
              if (controller.allBikes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                  child: Text(
                    'Select your active bike:',
                    style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  itemCount: controller.allBikes.length,
                  itemBuilder: (context, index) {
                    final bike = controller.allBikes[index];
                    final isActive = bike['bikeId'] == controller.activeBikeId.value;

                    return _BikeCard(
                      bike: bike,
                      isActive: isActive,
                      theme: theme,
                      // 1. Tapping the card sets the active bike globally
                      onCardTap: () {
                        controller.setAsActiveBike(bike['bikeId']);
                      },
                      // 2. Tapping Details sets it active AND explicitly passes data via arguments
                      onDetailsTap: () {
                        controller.setAsActiveBike(bike['bikeId']);

                        // Pass exact bike data as an argument to avoid mapping errors
                        Get.to(() => const BikeDetailScreen(), arguments: bike);
                      },
                    );
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
  final Map<String, dynamic> bike;
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
    return Container(
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
          // Top Section: The whole row is tappable to set active
          InkWell(
            onTap: onCardTap,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      image: bike['imageUrl'] != ''
                          ? DecorationImage(image: NetworkImage(bike['imageUrl']), fit: BoxFit.cover)
                          : null,
                    ),
                    child: bike['imageUrl'] == ''
                        ? Icon(Icons.two_wheeler, color: theme.primaryColor)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${bike['nickname']} - ${bike['brand']} ${bike['model']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${bike['registration']} • ${bike['year']}",
                          style: TextStyle(color: theme.hintColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

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
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Select',
                      style: TextStyle(color: theme.hintColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Bottom Section: Details Button
          InkWell(
            onTap: onDetailsTap,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn("${bike['currentOdometer']}", "km odo", theme),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text("View Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primaryColor)),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: 11)),
      ],
    );
  }
}