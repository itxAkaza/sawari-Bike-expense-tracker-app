import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../controllers/analytics/analytics_controller.dart';
import '../../../../controllers/mainBikeControllre/mainBike_Controllre.dart';


class MileageAnalyticsScreen extends StatelessWidget {
  const MileageAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsCtrl = Get.find<AnalyticsController>();
    final mainCtrl = Get.find<MainBikesController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('mileage_and_costs'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            final bike = mainCtrl.activeBike;
            if (bike == null) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  bike.brand.toUpperCase(),
                  style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            );
          })
        ],
      ),
      body: Obx(() {
        final bike = mainCtrl.activeBike;
        if (bike == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Stats Cards ---
              Row(
                children: [
                  Expanded(child: _buildTopCard(theme, 'avg_mileage'.tr, analyticsCtrl.avgMileage.value.toStringAsFixed(1), 'kml'.tr, theme.primaryColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTopCard(theme, 'cost_per_km'.tr, analyticsCtrl.costPerKm.value.toStringAsFixed(1), 'rs'.tr, theme.textTheme.bodyLarge!.color!)),
                ],
              ),
              const SizedBox(height: 16),

              // --- Line Chart (Mileage Per Tank) ---
              _buildChartContainer(
                theme,
                title: 'mileage_per_tank'.tr,
                actionText: 'last_8_fills'.tr,
                child: AspectRatio(
                  aspectRatio: 2,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor.withOpacity(0.2), strokeWidth: 1)),
                      titlesData: const FlTitlesData(show: false), // Hide axes matching design
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: analyticsCtrl.tankSpots.toList(),
                          isCurved: false,
                          color: theme.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: theme.primaryColor, strokeWidth: 2, strokeColor: theme.cardColor)
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Bar Chart (Monthly Spend) ---
              _buildChartContainer(
                theme,
                title: 'monthly_spend'.tr,
                child: AspectRatio(
                  aspectRatio: 1.8,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < analyticsCtrl.monthlyLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(analyticsCtrl.monthlyLabels[value.toInt()], style: TextStyle(color: theme.hintColor, fontSize: 10)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: analyticsCtrl.monthlyBarGroups.map((group) {
                        // Color the last bar primary, the rest muted
                        final isLast = group.x == analyticsCtrl.monthlyBarGroups.length - 1;
                        return BarChartGroupData(
                            x: group.x,
                            barRods: [
                              BarChartRodData(
                                toY: group.barRods[0].toY,
                                color: isLast ? theme.primaryColor : theme.dividerColor.withOpacity(0.5),
                                width: 24,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ]
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Donut Chart (Where the money goes) ---
              _buildChartContainer(
                theme,
                title: 'where_money_goes'.tr,
                child: Row(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: _buildPieSections(analyticsCtrl, theme),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${(analyticsCtrl.yearTotal.value / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('this_year'.tr.toUpperCase(), style: TextStyle(fontSize: 8, color: theme.hintColor)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow(theme, 'fuel'.tr, analyticsCtrl.yearFuel.value, analyticsCtrl.yearTotal.value, theme.primaryColor),
                          const SizedBox(height: 12),
                          _buildLegendRow(theme, 'maintenance'.tr, analyticsCtrl.yearMaint.value, analyticsCtrl.yearTotal.value, Colors.brown.shade400),
                          const SizedBox(height: 12),
                          _buildLegendRow(theme, 'repairs_and_other'.tr, analyticsCtrl.yearRepair.value, analyticsCtrl.yearTotal.value, Colors.blue.shade400),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Best Tank Info Card ---
              if (analyticsCtrl.bestTankMileage.value > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, color: theme.primaryColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${'best_tank'.tr}: ${analyticsCtrl.bestTankMileage.value.toStringAsFixed(1)} ${'kml'.tr} on ${analyticsCtrl.bestTankDate.value}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('best_tank_desc'.tr, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopCard(ThemeData theme, String title, String value, String unit, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.hintColor)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (unit == 'Rs.') Text("$unit ", style: TextStyle(fontSize: 12, color: theme.hintColor)),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: valueColor)),
              if (unit != 'Rs.') Text(" $unit", style: TextStyle(fontSize: 12, color: theme.hintColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(ThemeData theme, {required String title, String? actionText, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.hintColor)),
              if (actionText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(actionText.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(AnalyticsController ctrl, ThemeData theme) {
    double total = ctrl.yearTotal.value;
    if (total == 0) {
      return [PieChartSectionData(value: 1, color: theme.dividerColor.withOpacity(0.3), showTitle: false, radius: 15)];
    }
    return [
      PieChartSectionData(value: ctrl.yearFuel.value, color: theme.primaryColor, showTitle: false, radius: 15),
      PieChartSectionData(value: ctrl.yearMaint.value, color: Colors.brown.shade400, showTitle: false, radius: 15),
      PieChartSectionData(value: ctrl.yearRepair.value, color: Colors.blue.shade400, showTitle: false, radius: 15),
    ];
  }

  Widget _buildLegendRow(ThemeData theme, String label, double amount, double total, Color color) {
    int percentage = total > 0 ? ((amount / total) * 100).round() : 0;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Rs. ${amount.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text("$percentage%", style: TextStyle(color: theme.hintColor, fontSize: 10)),
          ],
        )
      ],
    );
  }
}