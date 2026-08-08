import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/bikeDetail/bikedetail_controller.dart';
import '../../../resources/assets/image_assets.dart';

class BikeDetailScreen extends StatelessWidget {
  const BikeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is initialized naturally by GetX. No manual onInit() here!
    final controller = Get.put(DetailController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('bike_profile'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.iconTheme.color),
            onPressed: () {
              // Edit bike functionality placeholder
            },
          )
        ],
      ),
      body: Obx(() {
        final bike = controller.activeBikeData;
        final currency = controller.appCurrency.value.split(' ')[0];

        if (bike.isEmpty) {
          return const Center(child: Text("Loading bike details..."));
        }

        // --- SAFELY FIXING FIREBASE NUMBERS TO PREVENT RED SCREEN CRASH ---
        // Firebase gives ints for whole numbers. 'num' safely handles both int and double.
        num maintenance = bike['totalMaintenanceSpend'] ?? 0;
        num repair = bike['totalRepairSpend'] ?? 0;
        double totalSpent = (maintenance + repair).toDouble();

        num currentOdo = bike['currentOdometer'] ?? 0;
        num firstOdo = bike['firstOdometer'] ?? 0;
        double totalDistance = (currentOdo - firstOdo).toDouble();

        num liters = bike['totalLiters'] ?? 0;
        double kml = 0.0;
        if (liters > 0) {
          kml = totalDistance / liters.toDouble();
        }

        int totalServices = bike['totalServices'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Header Card ---
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: bike['imageUrl'] != ''
                        ? NetworkImage(bike['imageUrl']) as ImageProvider
                        : const AssetImage(ImageAssets.bikeCard),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bike['nickname'],
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            "${bike['brand']} ${bike['model']} - ${bike['year']}",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ODOMETER", style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "${bike['currentOdometer']}",
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text("km", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bike['registration'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Analytics Row ---
              Row(
                children: [
                  Expanded(child: _buildMetricCard(theme, "$totalSpent $currency", 'spent_in_year'.tr)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard(theme, kml.toStringAsFixed(1), 'kml_average'.tr, isHighlight: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard(theme, "$totalServices", 'services'.tr)),
                ],
              ),
              const SizedBox(height: 24),

              // --- Details List ---
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildDetailRow(theme, 'brand'.tr, bike['brand']),
                    const Divider(height: 1),
                    _buildDetailRow(theme, 'model'.tr, bike['model']),
                    const Divider(height: 1),
                    _buildDetailRow(theme, 'year'.tr, bike['year']),
                    const Divider(height: 1),
                    _buildDetailRow(theme, 'registration'.tr, bike['registration']),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Action Buttons ---
              _buildWideButton(theme, 'view_mileage_analytics'.tr, () {}),
              const SizedBox(height: 12),
              _buildWideButton(theme, 'maintenance_schedule'.tr, () {}),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String value, String label, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isHighlight ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildWideButton(ThemeData theme, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }
}