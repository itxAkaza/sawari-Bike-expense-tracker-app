import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BikeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addBike(Map<String, dynamic> bikeData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User is not authenticated.");

    final docRef = _firestore.collection('bikes').doc();
    bikeData['bikeId'] = docRef.id;

    await docRef.set(bikeData);
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

  // --- NEW UPDATE FUNCTION ---
  Future<void> updateBike(String bikeId, Map<String, dynamic> bikeData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User is not authenticated.");

    await _firestore.collection('bikes').doc(bikeId).update(bikeData);
  }
}