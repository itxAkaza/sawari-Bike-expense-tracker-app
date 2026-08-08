import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BikeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addBike(Map<String, dynamic> bikeData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User is not authenticated.");

    // Generate a new document ID automatically
    final docRef = _firestore.collection('bikes').doc();

    // Attach the auto-generated ID and the user's UID to the payload
    bikeData['bikeId'] = docRef.id;


    await docRef.set(bikeData);
  }
}