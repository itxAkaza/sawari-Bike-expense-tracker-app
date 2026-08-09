import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/schedule_model.dart';


class ScheduleFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a continuous stream of schedules for a specific bike
  Stream<List<ScheduleModel>> getBikeSchedulesStream(String bikeId) {
    return _firestore
        .collection('bikes')
        .doc(bikeId)
        .collection('schedules')
        .orderBy('target', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScheduleModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Deletes a specific schedule
  Future<void> deleteSchedule(String bikeId, String scheduleId) async {
    await _firestore
        .collection('bikes')
        .doc(bikeId)
        .collection('schedules')
        .doc(scheduleId)
        .delete();
  }

  /// Handles the massive transaction of marking a schedule as done
  Future<void> markScheduleDoneBatch({
    required String bikeId,
    required ScheduleModel schedule,
    required double cost,
    required double newOdometer,
    required double masterCurrentOdo,
    required double masterTotalMaintenance,
    required DateTime now,
  }) async {
    final batch = _firestore.batch();
    final bikeRef = _firestore.collection('bikes').doc(bikeId);
    final historyRef = bikeRef.collection('history_logs').doc();
    final scheduleRef = bikeRef.collection('schedules').doc(schedule.scheduleId);

    // 1. Update Master Bike Stats
    batch.update(bikeRef, {
      'currentOdometer': newOdometer,
      'totalMaintenanceSpend': masterTotalMaintenance + cost,
    });

    // 2. Add History Log
    batch.set(historyRef, {
      'type': 'maintenance',
      'category': schedule.title, // e.g., "Oil change"
      'amount': cost,
      'odometer': newOdometer,
      'liters': null,
      'isOneTimeRepair': false,
      'note': 'Scheduled maintenance completed',
      'datetime': Timestamp.fromDate(now),
    });

    // 3. Update the Schedule for the next round
    dynamic newTarget;
    dynamic newLastDone;

    if (schedule.type == 'km') {
      newLastDone = newOdometer;
      newTarget = newOdometer + schedule.repeat;
    } else { // type == 'date'
      newLastDone = Timestamp.fromDate(now);
      // repeat is stored in months for dates
      // repeat is stored in months for dates
      DateTime nextDate = DateTime(now.year, (now.month + schedule.repeat).toInt(), now.day);
      newTarget = Timestamp.fromDate(nextDate);
    }

    batch.update(scheduleRef, {
      'lastDone': newLastDone,
      'target': newTarget,
    });

    // Commit all changes simultaneously
    await batch.commit();
  }

  /// Adds a new schedule to the active bike
  Future<void> addSchedule(String bikeId, Map<String, dynamic> data) async {
    final docRef = _firestore
        .collection('bikes')
        .doc(bikeId)
        .collection('schedules')
        .doc();

    data['scheduleId'] = docRef.id;
    await docRef.set(data);
  }
}