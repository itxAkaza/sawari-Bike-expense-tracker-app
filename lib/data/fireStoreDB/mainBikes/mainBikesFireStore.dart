import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/bike_model.dart';
// import 'bike_model.dart'; // Adjust path

class MainBikesFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<BikeModel>> getUserBikesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error("User not logged in");
    }

    return _firestore
        .collection('bikes')
        .where('userId', isEqualTo: user.uid)
    // REMOVED .orderBy('createdAt') to fix the Firebase Index crash!
        .snapshots()
        .map((snapshot) {

      var bikes = snapshot.docs.map((doc) {
        return BikeModel.fromMap(doc.data(), doc.id);
      }).toList();

      // SORT LOCALLY IN DART: Newest first
      bikes.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.now();
        final dateB = b.createdAt ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return bikes;
    });
  }
}