import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Email & Password Signup ---
  Future<UserCredential> signupWithEmailPassword(String email, String password, String name) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save initial user profile data matching your exact schema
    await _firestore.collection("users").doc(userCredential.user!.uid).set({
      "uid": userCredential.user!.uid,
      "name": name,
      "email": email,
      "isGuest": false,
      "theme": "auto",
      "currency": "PKR - Rs.",
      "petrolPrice": 272.5,
      "warnBeforeKm": 100,
      "warnBeforeDays": 7,
      "createdAt": FieldValue.serverTimestamp(), // Always use server time for accuracy
    });

    return userCredential;
  }

  // --- Email & Password Login ---
  Future<UserCredential> signinWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- Anonymous / Guest Login ---
  Future<UserCredential> signInAnonymously() async {
    final UserCredential userCredential = await _auth.signInAnonymously();

    // Verify if the guest doc already exists (in case they logged out and back in anonymously)
    final doc = await _firestore.collection("users").doc(userCredential.user!.uid).get();

    if (!doc.exists) {
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": "Guest",
        "email": "", // Guests don't have emails yet
        "isGuest": true,
        "theme": "auto",
        "currency": "PKR - Rs.",
        "petrolPrice": 272.5,
        "warnBeforeKm": 100,
        "warnBeforeDays": 7,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Convert Guest to Permanent User ---
  Future<UserCredential> convertGuestToPermanent(String email, String password, String name) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw Exception("No anonymous user found to convert.");
    }

    // 1. Create the credential with the new email and password
    final credential = EmailAuthProvider.credential(email: email, password: password);

    // 2. Link this credential to the existing anonymous UID
    final userCredential = await user.linkWithCredential(credential);

    // 3. Update their existing Firestore user document
    await _firestore.collection("users").doc(user.uid).update({
      "name": name,
      "email": email,
      "isGuest": false, // They are no longer a guest!
    });

    return userCredential;
  }

}