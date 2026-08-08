import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/history_model.dart';
// import 'history_log_model.dart'; // Adjust path

class HistoryFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a continuous stream of history logs for a specific bike
  Stream<List<HistoryLogModel>> getBikeHistoryStream(String bikeId) {
    return _firestore
        .collection('bikes')
        .doc(bikeId)
        .collection('history_logs')
        .orderBy('datetime', descending: true) // Newest logs first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HistoryLogModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}