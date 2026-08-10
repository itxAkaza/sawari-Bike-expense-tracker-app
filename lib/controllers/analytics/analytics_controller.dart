import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../mainBikeControllre/mainBike_Controllre.dart';
import '../history/history_controller.dart';
import '../../models/history_model.dart'; // Adjust path based on your structure

class AnalyticsController extends GetxController {
  final MainBikesController _mainCtrl = Get.find<MainBikesController>();
  final HistoryController _historyCtrl = Get.find<HistoryController>();

  // --- Lifetime Stats ---
  var avgMileage = 0.0.obs;
  var costPerKm = 0.0.obs;

  // --- Chart Data ---
  var tankSpots = <FlSpot>[].obs;
  var monthlyBarGroups = <BarChartGroupData>[].obs;
  var monthlyLabels = <String>[].obs;
  var pieSections = <PieChartSectionData>[].obs;

  // --- Best Tank ---
  var bestTankMileage = 0.0.obs;
  var bestTankDate = ''.obs;

  // --- This Year Totals ---
  var yearTotal = 0.0.obs;
  var yearFuel = 0.0.obs;
  var yearMaint = 0.0.obs;
  var yearRepair = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _calculateAll();

    // Recalculate if history logs change (new fuel added, etc.)
    ever(_historyCtrl.historyLogs, (_) => _calculateAll());

    // Recalculate if user manually switches the active bike
    ever(_mainCtrl.selectedBikeId, (_) => _calculateAll());

    // THE FIX: Recalculate when Firebase finishes downloading the bikes list on app boot!
    ever(_mainCtrl.bikes, (_) => _calculateAll());
  }

  void _calculateAll() {
    final bike = _mainCtrl.activeBike;
    final logs = _historyCtrl.historyLogs;

    if (bike == null) return;

    // 1. Lifetime Stats
    double distance = bike.currentOdometer - bike.firstOdometer;
    if (distance > 0 && bike.totalLiters > 0) {
      avgMileage.value = distance / bike.totalLiters;
    } else {
      avgMileage.value = 0.0;
    }

    double totalSpend = bike.totalFuelSpend + bike.totalMaintenanceSpend + bike.totalRepairSpend;
    if (distance > 0) {
      costPerKm.value = totalSpend / distance;
    } else {
      costPerKm.value = 0.0;
    }

    // 2. Mileage Per Tank (Line Chart)
    _calculateTankMileage(logs);

    // 3. Monthly Spend (Bar Chart)
    _calculateMonthlySpend(logs);

    // 4. Where the Money Goes - THIS YEAR (Donut Chart)
    _calculateYearlyPieChart(logs);
  }

  void _calculateTankMileage(List<HistoryLogModel> allLogs) {
    // Filter fuel logs and ensure datetime is NOT null
    final fuelLogs = allLogs.where((l) => l.type == 'fuel' && l.datetime != null).toList();

    // Now it is safe to use ! since we filtered nulls above
    fuelLogs.sort((a, b) => a.datetime!.compareTo(b.datetime!));

    List<FlSpot> spots = [];
    double bestKml = 0.0;
    String bestDate = '';

    for (int i = 1; i < fuelLogs.length; i++) {
      double dist = fuelLogs[i].odometer - fuelLogs[i - 1].odometer;
      double liters = fuelLogs[i].liters ?? 0.0;

      if (dist > 0 && liters > 0) {
        double kml = dist / liters;
        // Keep track of the best tank
        if (kml > bestKml) {
          bestKml = kml;
          bestDate = DateFormat('d MMM').format(fuelLogs[i].datetime!);
        }
        spots.add(FlSpot((i - 1).toDouble(), kml));
      }
    }

    // Keep only the last 8 fills
    if (spots.length > 8) {
      spots = spots.sublist(spots.length - 8);
      // Re-index X values for the chart starting at 0
      for (int i = 0; i < spots.length; i++) {
        spots[i] = FlSpot(i.toDouble(), spots[i].y);
      }
    }

    tankSpots.assignAll(spots);
    bestTankMileage.value = bestKml;
    bestTankDate.value = bestDate;
  }

  void _calculateMonthlySpend(List<HistoryLogModel> logs) {
    List<BarChartGroupData> bars = [];
    List<String> labels = [];
    DateTime now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      DateTime targetMonth = DateTime(now.year, now.month - i, 1);
      double monthTotal = 0;

      for (var log in logs) {
        // Null check added before accessing .year and .month
        if (log.datetime != null && log.datetime!.year == targetMonth.year && log.datetime!.month == targetMonth.month) {
          monthTotal += log.amount;
        }
      }

      labels.add(DateFormat('MMM').format(targetMonth));
      bars.add(BarChartGroupData(
        x: 5 - i,
        barRods: [
          BarChartRodData(
            toY: monthTotal,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      ));
    }

    monthlyLabels.assignAll(labels);
    monthlyBarGroups.assignAll(bars);
  }

  void _calculateYearlyPieChart(List<HistoryLogModel> logs) {
    int currentYear = DateTime.now().year;

    double f = 0, m = 0, r = 0;

    for (var log in logs) {
      // Null check added before accessing .year
      if (log.datetime != null && log.datetime!.year == currentYear) {
        if (log.type == 'fuel') f += log.amount;
        else if (log.type == 'maintenance') m += log.amount;
        else if (log.type == 'repair') r += log.amount;
      }
    }

    yearFuel.value = f;
    yearMaint.value = m;
    yearRepair.value = r;
    yearTotal.value = f + m + r;
  }
}