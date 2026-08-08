import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BailRecordService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  static Future<Map<String, String>> getEngineerDetails() async
  {
    try {
      String? uid = getCurrentUserId();
      if (uid == null) return {'name': 'Unknown', 'employeeId': 'Unknown'};

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null)
      {
        return
          {
          'name': doc.data()!['name'] ?? 'Unknown',
          'employeeId': doc.data()!['employeeId'] ?? 'Unknown',
        };
      }
      return {'name': 'Unknown', 'employeeId': 'Unknown'};
    } catch (e)
    {
      return {'name': 'Unknown', 'employeeId': 'Unknown'};
    }

  }

  static Future<List<String>> fetchSuppliers() async
  {
    try {
      final snapshot = await _firestore.collection('vendors').get();
      return snapshot.docs
          .map((doc) => doc.data().containsKey('name')
          ? doc['name'] as String
          : 'Unknown Vendor')
          .toList();
    } catch (e)
    {
      return [];
    }
  }

  static Future<void> saveBaleData({
    required String userId,
    required String baleId,
    required Map<String, dynamic> baleData,
  }) async {
    try {

      baleData['createdAt'] = FieldValue.serverTimestamp();


      int newBaleCount = int.tryParse(baleData['baleCount'].toString()) ?? 0;
      double addedAmount = double.tryParse(baleData['price'].toString()) ?? 0.0;


      WriteBatch batch = _firestore.batch();


      DocumentReference baleDocRef = _firestore
          .collection('BailRecord')
          .doc(userId)
          .collection('bail_data')
          .doc(baleId);

      batch.set(baleDocRef, baleData);


      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
      batch.set(
        userDocRef,
        {
          'totalBalesAmount': FieldValue.increment(addedAmount)
        },
        SetOptions(merge: true),
      );


      DocumentReference statsDocRef = _firestore.collection('records').doc('dashboard_stats');
      batch.set(
        statsDocRef,
        {
          'total_gate_passes': FieldValue.increment(1),
          'total_bales_count': FieldValue.increment(newBaleCount),
        },
        SetOptions(merge: true),
      );


      await batch.commit();

    } on FirebaseException catch (e)
    {
      switch (e.code) {
        case 'permission-denied':
          throw Exception('Permission denied. You do not have access to save this record.');
        case 'unavailable':
          throw Exception('Network error. Please check your internet connection.');
        default:
          throw Exception('Database error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to save to Firebase: $e');
    }
  }
}