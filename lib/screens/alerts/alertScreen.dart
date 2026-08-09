import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../controllers/mainBikeControllre/mainBike_Controllre.dart';
import '../../controllers/schedule/schedule_controller.dart';
import '../../models/schedule_model.dart';
import '../bikes/bikeDetail/maintenanceSchedule/maintenanceScheduleScreen.dart';

// import '../../controllers/schedule/schedule_controller.dart';
// import '../../controllers/mainBikeControllre/mainBike_Controllre.dart';
// import '../../models/schedule_model.dart';
// import '../../resources/assets/image_assets.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleCtrl = Get.put(ScheduleController());
    final mainCtrl = Get.find<MainBikesController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('nav_alerts'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: Obx(() {
        if (scheduleCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bike = mainCtrl.activeBike;
        if (bike == null || scheduleCtrl.schedules.isEmpty) {
          return _buildEmptyState(theme);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scheduleCtrl.schedules.length,
          itemBuilder: (context, index) {
            final schedule = scheduleCtrl.schedules[index];
            return _buildScheduleCard(context, schedule, bike, scheduleCtrl, theme);
          },
        );
      }),
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
              child: Icon(Icons.check_circle_outline, size: 80, color: theme.primaryColor.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Text('empty_alerts_title'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('empty_alerts_desc'.tr, textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor, fontSize: 14, height: 1.5)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const MaintenanceScheduleScreen());
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Set up maintenance schedule', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, ScheduleModel schedule, dynamic bike, ScheduleController ctrl, ThemeData theme) {
    bool isKm = schedule.type == 'km';
    double progress = 0.0;
    bool isOverdue = false;
    String statusText = '';
    String subText = '';

    // Mathematical Progress Calculation
    if (isKm) {
      double targetOdo = schedule.target as double;
      double lastOdo = schedule.lastDone as double;
      double repeat = schedule.repeat;
      double currentOdo = bike.currentOdometer;

      progress = (currentOdo - lastOdo) / repeat;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;

      double diff = targetOdo - currentOdo;
      isOverdue = diff <= 0;

      subText = "Every ${repeat.toInt()} km · last at ${lastOdo.toInt()} km";
      if (isOverdue) {
        statusText = "${'overdue_by'.tr} ${diff.abs().toInt()} km";
      } else {
        statusText = "Due in ${diff.toInt()} km";
      }
    } else {
      // Date Logic calculations
      DateTime targetDate = (schedule.target as Timestamp).toDate();
      DateTime lastDate = (schedule.lastDone as Timestamp).toDate();
      DateTime now = DateTime.now();

      int totalDays = targetDate.difference(lastDate).inDays;
      int daysPassed = now.difference(lastDate).inDays;

      progress = totalDays > 0 ? (daysPassed / totalDays) : 1.0;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;

      int daysLeft = targetDate.difference(now).inDays;
      isOverdue = daysLeft <= 0;

      subText = "Due ${targetDate.day}/${targetDate.month}/${targetDate.year}";
      if (isOverdue) {
        statusText = "${'overdue_by'.tr} ${daysLeft.abs()} days";
      } else {
        statusText = "$daysLeft ${'days_left'.tr}";
      }
    }

    // Color logic
    Color statusColor = isOverdue ? Colors.redAccent : (progress > 0.8 ? Colors.orangeAccent : theme.primaryColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(isKm ? Icons.water_drop : Icons.security, color: statusColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subText, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  isOverdue ? 'due'.tr : 'on_track'.tr,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13))),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => ctrl.cancelSchedule(schedule.scheduleId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.hintColor, side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text('cancel'.tr, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showMarkDoneDialog(context, schedule, ctrl, theme, bike),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor, foregroundColor: theme.textTheme.bodyLarge?.color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: theme.dividerColor)),
                      elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text('✓ ${'mark_done'.tr}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }



  void _showMarkDoneDialog(BuildContext context, ScheduleModel schedule, ScheduleController ctrl, ThemeData theme, dynamic bike) {
    final costController = TextEditingController();

    // SMART PRE-FILL: Suggest the target odometer so the user doesn't have to type it!
    double suggestedOdo = bike.currentOdometer;
    if (schedule.type == 'km') {
      double targetOdo = schedule.target as double;
      if (targetOdo > bike.currentOdometer) {
        suggestedOdo = targetOdo;
      }
    }

    final odoController = TextEditingController(text: suggestedOdo.toInt().toString());

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('mark_done_title'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cost (Required)', // Updated label
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: odoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Odometer (Required)', // Updated label
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.speed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr, style: TextStyle(color: theme.hintColor))),
          ElevatedButton(
            onPressed: () => ctrl.markAsDone(schedule, costController.text, odoController.text),
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('mark_done'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

}