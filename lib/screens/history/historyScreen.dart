import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/history/history_controller.dart'; // Adjust path
import '../../controllers/more/more_controller.dart'; // Adjust path
import '../../models/history_model.dart'; // Adjust path

import '../bikes/bikeDetail/milageAnalytics/mileageAnalyticsScreen.dart'; // Adjust path

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCtrl = Get.find<HistoryController>();
    final moreCtrl = Get.find<MoreController>();
    final theme = Theme.of(context);

    // Local reactive state for the filter chips
    final RxString selectedFilter = 'All'.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text('nav_history'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart, color: theme.iconTheme.color),
            onPressed: () => Get.to(() => const MileageAnalyticsScreen()),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Filter Row ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => Row(
              children: [
                _buildFilterChip('All', 'filter_all'.tr, selectedFilter, theme),
                const SizedBox(width: 8),
                _buildFilterChip('fuel', 'filter_fuel'.tr, selectedFilter, theme),
                const SizedBox(width: 8),
                _buildFilterChip('maintenance', 'filter_service'.tr, selectedFilter, theme),
                const SizedBox(width: 8),
                _buildFilterChip('repair', 'filter_repairs'.tr, selectedFilter, theme),
              ],
            )),
          ),

          // --- History List ---
          Expanded(
            child: Obx(() {
              if (historyCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final logs = historyCtrl.historyLogs;
              if (logs.isEmpty) {
                return _buildEmptyState(theme);
              }

              // Filter Logic
              final filteredLogs = logs.where((log) {
                if (selectedFilter.value == 'All') return true;
                return log.type == selectedFilter.value;
              }).toList();

              if (filteredLogs.isEmpty) {
                return _buildEmptyState(theme);
              }

              // Grouping Logic by Month & Year
              Map<String, List<HistoryLogModel>> groupedLogs = {};
              for (var log in filteredLogs) {
                if (log.datetime == null) continue;
                String monthYear = DateFormat('MMM yyyy').format(log.datetime!).toUpperCase();
                if (!groupedLogs.containsKey(monthYear)) {
                  groupedLogs[monthYear] = [];
                }
                groupedLogs[monthYear]!.add(log);
              }

              final currencySymbol = moreCtrl.currency.value.split(' ')[0];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedLogs.length,
                itemBuilder: (context, index) {
                  String monthYear = groupedLogs.keys.elementAt(index);
                  List<HistoryLogModel> monthLogs = groupedLogs[monthYear]!;

                  // Calculate Month Total
                  double monthTotal = monthLogs.fold(0.0, (sum, item) => sum + item.amount);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Header & Total
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(monthYear, style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                            Text("$currencySymbol ${monthTotal.toInt()}", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),

                      // Month Group Card Container
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Let the outer list scroll
                          itemCount: monthLogs.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                          itemBuilder: (context, logIndex) {
                            final log = monthLogs[logIndex];
                            return _buildHistoryItem(log, currencySymbol, theme);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, RxString selectedFilter, ThemeData theme) {
    bool isSelected = selectedFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) selectedFilter.value = value;
      },
      selectedColor: theme.primaryColor.withOpacity(0.1),
      backgroundColor: theme.scaffoldBackgroundColor,
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : theme.hintColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? theme.primaryColor : theme.dividerColor),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildHistoryItem(HistoryLogModel log, String currencySymbol, ThemeData theme) {
    // Dynamic styling based on log type
    Color iconColor;
    IconData iconData;

    switch (log.type) {
      case 'fuel':
        iconColor = Colors.teal;
        iconData = Icons.local_gas_station_outlined;
        break;
      case 'maintenance':
        iconColor = Colors.orange;
        iconData = Icons.build_outlined;
        break;
      case 'repair':
      default:
        iconColor = Colors.redAccent;
        iconData = Icons.build_circle_outlined;
        break;
    }

    String formattedDate = log.datetime != null ? DateFormat('d MMM').format(log.datetime!) : '';

    // Check if there is a note, otherwise just append Odometer
    String subtitle = "$formattedDate · ${log.odometer.toInt()} km";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount
          Text(
            "$currencySymbol ${log.amount.toInt()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
              child: Icon(Icons.history, size: 80, color: theme.primaryColor.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Text('empty_history_title'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('empty_history_desc'.tr, textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}