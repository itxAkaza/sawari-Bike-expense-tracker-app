import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawari/screens/bikes/bikeDetail/bikeDetailScreen.dart';

import '../../controllers/home/home_controller.dart';
import '../../controllers/homeBottomBar/home_bottomBar_controller.dart';
import '../../controllers/mainBikeControllre/mainBike_Controllre.dart';
import '../../controllers/more/more_controller.dart';
import '../../controllers/history/history_controller.dart';
import '../../controllers/schedule/schedule_controller.dart';
import '../../resources/route/routes_names.dart';

import '../bikes/AddBike/addBikeScreen.dart';
import '../bikes/bikeDetail/milageAnalytics/mileageAnalyticsScreen.dart'; // Adjust this path if needed

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard Get.put for transient UI state
    final homeCtrl = Get.put(HomeController());

    // Get.find for our permanent data engines
    final mainCtrl = Get.find<MainBikesController>();
    final moreCtrl = Get.find<MoreController>();
    final historyCtrl = Get.find<HistoryController>();
    final scheduleCtrl = Get.find<ScheduleController>();
    final bottomBarCtrl = Get.find<MainHomeViewModel>(); // Use your actual controller name!
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (mainCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==========================================
          // --- EMPTY STATE HANDLING ---
          // ==========================================
          if (mainCtrl.bikes.isEmpty) {
            return _buildEmptyHomeState(theme, moreCtrl.userName.value);
          }

          final bike = mainCtrl.activeBike;
          if (bike == null) return const Center(child: CircularProgressIndicator());

          // --- Mathematics & Formatting ---
          String currentDate = DateFormat('EEEE, d MMM').format(DateTime.now());
          double distance = bike.currentOdometer - bike.firstOdometer;
          double kml = bike.totalLiters > 0 ? (distance / bike.totalLiters) : 0.0;

          double thisMonthFuel = 0.0;
          DateTime now = DateTime.now();
          for (var log in historyCtrl.historyLogs) {
            if (log.type == 'fuel' && log.datetime != null &&
                log.datetime!.year == now.year && log.datetime!.month == now.month) {
              thisMonthFuel += log.amount;
            }
          }

          // ==========================================
          // --- DYNAMIC HEALTH CALCULATION ---
          // ==========================================
          bool needsCare = false;
          if (scheduleCtrl.schedules.isNotEmpty) {
            final urgent = scheduleCtrl.schedules.first;
            if (urgent.type == 'km') {
              double diff = (urgent.target as double) - bike.currentOdometer;
              if (diff <= 50) needsCare = true; // Mark needs care if within 50km or overdue
            } else {
              int daysLeft = (urgent.target as Timestamp).toDate().difference(DateTime.now()).inDays;
              if (daysLeft <= 7) needsCare = true; // Mark needs care if within 7 days or overdue
            }
          }

          Color healthColor = needsCare ? Colors.orange : Colors.green;
          String healthText = needsCare ? 'needs_care'.tr : 'healthy'.tr;
          IconData healthIcon = needsCare ? Icons.build_circle : Icons.health_and_safety;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentDate, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "${'salam'.tr} ${moreCtrl.userName.value} 👋",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Active Bike Card ---
                GestureDetector(
                  onTap: () => Get.to(() => const BikeDetailScreen()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor.withOpacity(0.9), theme.primaryColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${bike.nickname} · ${bike.brand} ${bike.model}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white70),
                          ],
                        ),
                        Text("${bike.registration} · ${bike.year}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 24),
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
                                    Text("${bike.currentOdometer.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                                    const SizedBox(width: 4),
                                    const Text("km", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('avg_mileage'.tr, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5)),
                                Text("${kml.toStringAsFixed(1)} km/l", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Action Buttons ---
                Row(
                  children: [
                    Expanded(child: _buildActionButton(theme, 'add_fuel'.tr, Icons.local_gas_station, true, () => _showFuelSheet(context, homeCtrl, theme, moreCtrl.currency.value))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(theme, 'expense'.tr, Icons.sell_outlined, false, () => _showExpenseSheet(context, homeCtrl, theme, moreCtrl.currency.value))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(theme, 'service'.tr, Icons.build_outlined, false, () => _showRepairSheet(context, homeCtrl, theme, moreCtrl.currency.value))),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Mid Section Dashboards ---
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => Get.to(() => const MileageAnalyticsScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withOpacity(0.3))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('this_month_fuel'.tr, style: TextStyle(color: theme.hintColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 8),
                              Text("Rs. ${thisMonthFuel.toInt()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // --- DYNAMIC HEALTH CARD ---
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(RoutesNames.alertScreen),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withOpacity(0.3))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(healthIcon, color: healthColor, size: 28),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('health'.tr, style: TextStyle(color: theme.hintColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  Text(healthText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: healthColor)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- URGENT ALERT CARD (Using ScheduleController) ---
                _buildUrgentAlertCard(scheduleCtrl, bike, theme),
                const SizedBox(height: 24),

                // --- Recent Activity ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('recent_activity'.tr, style: TextStyle(color: theme.hintColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    GestureDetector(
                      // Change '1' to whatever index your History tab is!
                      // (e.g., 0 = Home, 1 = History, 2 = Alerts, 3 = Bikes, etc.)
                      onTap: () => bottomBarCtrl.setIndex(1),
                      child: Text('see_all'.tr, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // History List (Take top 3)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyCtrl.historyLogs.length > 3 ? 3 : historyCtrl.historyLogs.length,
                  itemBuilder: (context, index) {
                    final log = historyCtrl.historyLogs[index];
                    return _buildRecentActivityItem(log, moreCtrl.currency.value, theme);
                  },
                ),
                const SizedBox(height: 80), // Padding for bottom bar
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // --- EMPTY STATE WIDGET ---
  // ==========================================
  Widget _buildEmptyHomeState(ThemeData theme, String userName) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.garage, size: 80, color: theme.primaryColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),
          Text("${'salam'.tr} $userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('welcome_garage'.tr, style: TextStyle(fontSize: 18, color: theme.hintColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text('home_empty_desc'.tr, textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor, fontSize: 14, height: 1.5)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddBikeScreen()),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('add_first_bike'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // --- URGENT ALERT CARD LOGIC ---
  // ==========================================
  Widget _buildUrgentAlertCard(ScheduleController scheduleCtrl, dynamic bike, ThemeData theme) {
    if (scheduleCtrl.schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withOpacity(0.3))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Colors.green, size: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('all_caught_up'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('no_urgent_alerts'.tr, style: TextStyle(color: theme.hintColor, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
    }

    // Grab the first schedule (It's sorted by target ascending in Firestore!)
    final urgent = scheduleCtrl.schedules.first;
    bool isOverdue = false;
    double progress = 0.0;
    String statusText = '';

    if (urgent.type == 'km') {
      double targetOdo = urgent.target as double;
      double lastOdo = urgent.lastDone as double;
      double currentOdo = bike.currentOdometer;

      progress = (currentOdo - lastOdo) / urgent.repeat;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;

      double diff = targetOdo - currentOdo;
      isOverdue = diff <= 0;
      statusText = isOverdue ? "${'overdue_by'.tr} ${diff.abs().toInt()} km" : "Due in ${diff.toInt()} km";
    } else {
      DateTime targetDate = (urgent.target as Timestamp).toDate();
      DateTime lastDate = (urgent.lastDone as Timestamp).toDate();
      DateTime now = DateTime.now();

      int totalDays = targetDate.difference(lastDate).inDays;
      int daysPassed = now.difference(lastDate).inDays;

      progress = totalDays > 0 ? (daysPassed / totalDays) : 1.0;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;

      int daysLeft = targetDate.difference(now).inDays;
      isOverdue = daysLeft <= 0;
      statusText = isOverdue ? "${'overdue_by'.tr} ${daysLeft.abs()} days" : "$daysLeft ${'days_left'.tr}";
    }

    Color statusColor = isOverdue ? Colors.redAccent : (progress > 0.8 ? Colors.orangeAccent : theme.primaryColor);

    return GestureDetector(
      onTap: () => Get.toNamed(RoutesNames.alertScreen),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(urgent.type == 'km' ? Icons.water_drop : Icons.security, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${urgent.title} — $statusText",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: statusColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text("${(progress * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: statusColor)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress, minHeight: 6,
                backgroundColor: statusColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // --- EXISTING HELPERS ---
  // ==========================================

  Widget _buildActionButton(ThemeData theme, String label, IconData icon, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: theme.dividerColor.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: isPrimary ? Colors.white : theme.iconTheme.color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isPrimary ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityItem(dynamic log, String currency, ThemeData theme) {
    String formattedDate = log.datetime != null ? DateFormat('d MMM').format(log.datetime!) : '';
    Color iconColor = log.type == 'fuel' ? Colors.teal : (log.type == 'maintenance' ? Colors.orange : Colors.redAccent);
    IconData iconData = log.type == 'fuel' ? Icons.local_gas_station_outlined : (log.type == 'maintenance' ? Icons.build_outlined : Icons.build_circle_outlined);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withOpacity(0.3))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(iconData, color: iconColor, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("$formattedDate · ${log.odometer.toInt()} km", style: TextStyle(color: theme.hintColor, fontSize: 12)),
              ],
            ),
          ),
          Text("${currency.split(' ')[0]} ${log.amount.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // --- Bottom sheets remain exactly the same as provided ---
  void _showFuelSheet(BuildContext context, HomeController ctrl, ThemeData theme, String currency) {
    ctrl.openBottomSheet('fuel');
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Row(children: [Icon(Icons.local_gas_station, color: theme.primaryColor), const SizedBox(width: 8), Text('add_fuel'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              _buildInputRow(theme, ctrl.amountController, 'amount_paid'.tr, currency.split(' ')[0]),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickButton(theme, '500', () => ctrl.setQuickAmount('500')),
                  const SizedBox(width: 8),
                  _buildQuickButton(theme, '1000', () => ctrl.setQuickAmount('1000')),
                  const SizedBox(width: 8),
                  _buildQuickButton(theme, '1500', () => ctrl.setQuickAmount('1500')),
                ],
              ),
              const SizedBox(height: 24),
              _buildInputRow(theme, ctrl.odoController, 'odometer_now'.tr, 'km'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : () => ctrl.submitEntry('fuel'),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: ctrl.isSaving.value ? const CircularProgressIndicator(color: Colors.white) : Text('save_fuel_entry'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showExpenseSheet(BuildContext context, HomeController ctrl, ThemeData theme, String currency) {
    ctrl.openBottomSheet('maintenance');
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Row(children: [Icon(Icons.sell_outlined, color: theme.primaryColor), const SizedBox(width: 8), Text('add_expense'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              Obx(() => Wrap(
                spacing: 8, runSpacing: 8,
                children: ctrl.expenseCategories.map((cat) => _buildChoiceChip(theme, cat, ctrl.selectedCategory.value == cat, () => ctrl.selectedCategory.value = cat)).toList(),
              )),
              const SizedBox(height: 24),
              _buildInputRow(theme, ctrl.amountController, 'amount_paid'.tr, currency.split(' ')[0]),
              const SizedBox(height: 24),
              _buildInputRow(theme, ctrl.odoController, 'odometer_now'.tr, 'km'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : () => ctrl.submitEntry('maintenance'),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: ctrl.isSaving.value ? const CircularProgressIndicator(color: Colors.white) : Text('save_expense'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showRepairSheet(BuildContext context, HomeController ctrl, ThemeData theme, String currency) {
    ctrl.openBottomSheet('repair');
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Row(children: [Icon(Icons.build_outlined, color: Colors.redAccent), const SizedBox(width: 8), Text('one_time_repair'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              Obx(() => Wrap(
                spacing: 8, runSpacing: 8,
                children: ctrl.repairCategories.map((cat) => _buildChoiceChip(theme, cat, ctrl.selectedCategory.value == cat, () => ctrl.selectedCategory.value = cat, isDanger: true)).toList(),
              )),
              const SizedBox(height: 24),
              _buildInputRow(theme, ctrl.amountController, 'amount_paid'.tr, currency.split(' ')[0]),
              const SizedBox(height: 24),
              _buildInputRow(theme, ctrl.odoController, 'odometer_now'.tr, 'km'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : () => ctrl.submitEntry('repair'),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: ctrl.isSaving.value ? const CircularProgressIndicator(color: Colors.white) : Text('save_repair'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputRow(ThemeData theme, TextEditingController ctrl, String label, String prefix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Row(
            children: [
              Text(prefix, style: TextStyle(color: theme.hintColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickButton(ThemeData theme, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withOpacity(0.3))),
        child: Text("Rs. $text", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildChoiceChip(ThemeData theme, String key, bool isSelected, VoidCallback onTap, {bool isDanger = false}) {
    Color activeColor = isDanger ? Colors.redAccent : theme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? activeColor : theme.dividerColor.withOpacity(0.3), width: isSelected ? 2 : 1),
        ),
        child: Text(key.tr, style: TextStyle(color: isSelected ? activeColor : theme.hintColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ),
    );
  }
}