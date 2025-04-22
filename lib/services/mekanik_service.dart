import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mekanik_model.dart';

class MekanikService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch Mekanik by Specialization
  Future<List<Mekanik>> fetchMekanik(String specialization) async {
    try {
      final querySnapshot = await _firestore
          .collection('mekanik')
          .where('specialization', isEqualTo: specialization)
          .get();
      return querySnapshot.docs
          .map((doc) => Mekanik.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching mekanik: $e');
    }
  }

  // Register Mekanik
  Future<void> registerMekanik({
    required String email,
    required String password,
    required Mekanik mekanik,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save mekanik data in Firestore
      await _firestore.collection('mekanik').doc(userCredential.user?.uid).set({
        'id': userCredential.user?.uid,
        'name': mekanik.name,
        'specialization': mekanik.specialization,
        'rating': mekanik.rating,
        'address': mekanik.address,
        'location': mekanik.location,
        'image': mekanik.image,
        'description': mekanik.description,
        'price': mekanik.price,
        'availability': mekanik.availability,
        'email': email,
        'phone': mekanik.phone,
      });
    } catch (e) {
      throw Exception('Error registering mekanik: $e');
    }
  }

  // Login Mekanik
  Future<User?> loginMekanik({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Error logging in mekanik: $e');
    }
  }
}
