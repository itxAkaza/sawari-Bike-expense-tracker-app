import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LabEngineerFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;


  static Future<Map<String, dynamic>?> getUserProfile() async
  {
    String? uid = currentUserId;
    if (uid == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists)
    {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }



  static Future<List<Map<String, dynamic>>> getRecentBales() async
  {
    String? uid = currentUserId;
    if (uid == null) return [];


    QuerySnapshot snapshot = await _firestore
        .collection('BailRecord')
        .doc(uid)
        .collection('bail_data')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc)
    {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id;
      return data;
    }).toList();

  }
}