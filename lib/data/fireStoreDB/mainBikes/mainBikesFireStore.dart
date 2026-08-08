import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/bike_model.dart';
// import 'bike_model.dart'; // Adjust path

class MainBikesFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns a continuous stream of all bikes mapped directly to BikeModel
  Stream<List<BikeModel>> getUserBikesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error("User not logged in");
    }

    return _firestore
        .collection('bikes')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BikeModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}