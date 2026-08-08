import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/schedule_model.dart';
// import 'schedule_model.dart'; // Adjust path

class ScheduleFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a continuous stream of schedules for a specific bike
  Stream<List<ScheduleModel>> getBikeSchedulesStream(String bikeId) {
    return _firestore
        .collection('bikes')
        .doc(bikeId)
        .collection('schedules')
        .orderBy('target', descending: false) // False = Ascending (Due soonest at the top)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScheduleModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}