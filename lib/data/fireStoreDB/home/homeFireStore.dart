import 'package:cloud_firestore/cloud_firestore.dart';

class HomeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLogAndUpdateBikeBatch({
    required String bikeId,
    required Map<String, dynamic> logData,
    required double amount,
    required double newOdometer,
    required double? liters,
    required String type, // 'fuel', 'maintenance', 'repair'
  }) async {
    final batch = _firestore.batch();
    final bikeRef = _firestore.collection('bikes').doc(bikeId);
    final historyRef = bikeRef.collection('history_logs').doc();

    // 1. Add History Log
    logData['logId'] = historyRef.id;
    batch.set(historyRef, logData);

    // 2. Prepare Bike Updates
    Map<String, dynamic> bikeUpdates = {
      'currentOdometer': newOdometer,
    };

    if (type == 'fuel') {
      bikeUpdates['totalFuelSpend'] = FieldValue.increment(amount);
      bikeUpdates['totalLiters'] = FieldValue.increment(liters ?? 0);
    } else if (type == 'maintenance') {
      bikeUpdates['totalMaintenanceSpend'] = FieldValue.increment(amount);
    } else if (type == 'repair') {
      bikeUpdates['totalRepairSpend'] = FieldValue.increment(amount);
    }

    // 3. Update Master Bike Stats
    batch.update(bikeRef, bikeUpdates);

    // Commit transaction
    await batch.commit();
  }
}