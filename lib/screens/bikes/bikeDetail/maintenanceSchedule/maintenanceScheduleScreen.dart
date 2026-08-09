import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../../controllers/mainBikeControllre/mainBike_Controllre.dart';
import '../../../../controllers/schedule/schedule_controller.dart';

// import '../../controllers/schedule/schedule_controller.dart';
// import '../../controllers/mainBikeControllre/mainBike_Controllre.dart';

class MaintenanceScheduleScreen extends StatelessWidget {
  const MaintenanceScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleCtrl = Get.find<ScheduleController>();
    final mainCtrl = Get.find<MainBikesController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('maintenance'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_a_schedule'.tr.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.hintColor),
            ),
            const SizedBox(height: 16),

            // Outer Form Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TITLE INPUT ---
                  Text('name'.tr.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: scheduleCtrl.titleController,
                    decoration: InputDecoration(
                      hintText: 'eg_chain_adjustment'.tr,
                      hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TOGGLE SWITCH (KM vs MONTHS) ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => scheduleCtrl.toggleMode(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: scheduleCtrl.isKmMode.value ? theme.cardColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: scheduleCtrl.isKmMode.value ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                              ),
                              child: Center(child: Text('every_x_km'.tr, style: TextStyle(fontWeight: scheduleCtrl.isKmMode.value ? FontWeight.bold : FontWeight.normal, color: scheduleCtrl.isKmMode.value ? theme.textTheme.bodyLarge?.color : theme.hintColor))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => scheduleCtrl.toggleMode(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !scheduleCtrl.isKmMode.value ? theme.cardColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !scheduleCtrl.isKmMode.value ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                              ),
                              child: Center(child: Text('every_x_months'.tr, style: TextStyle(fontWeight: !scheduleCtrl.isKmMode.value ? FontWeight.bold : FontWeight.normal, color: !scheduleCtrl.isKmMode.value ? theme.textTheme.bodyLarge?.color : theme.hintColor))),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(height: 20),

                  // --- REPEAT & LAST DONE ROW ---
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scheduleCtrl.isKmMode.value ? 'repeat_every_km'.tr : 'repeat_every_months'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor, letterSpacing: 1.0)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: scheduleCtrl.repeatController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                hintText: scheduleCtrl.isKmMode.value ? '1000' : '12',
                                filled: true, fillColor: theme.scaffoldBackgroundColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scheduleCtrl.isKmMode.value ? 'last_done_km'.tr : 'last_done_days'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor, letterSpacing: 1.0)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: scheduleCtrl.lastDoneController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                hintText: scheduleCtrl.isKmMode.value ? '45350' : '0',
                                filled: true, fillColor: theme.scaffoldBackgroundColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 24),

                  // --- ADD BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Obx(() => ElevatedButton(
                      onPressed: scheduleCtrl.isSaving.value ? null : scheduleCtrl.saveNewSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: scheduleCtrl.isSaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('add_schedule'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}