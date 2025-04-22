import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Save user data to Firestore
      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          phone: phone,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }
      return null; // No errors
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  // Login User dengan validasi koleksi email
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Cek apakah email ada di koleksi 'users'
        var userDoc = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          return null; // Login berhasil, email ditemukan di users
        } else {
          // Jika tidak ada di users, cek di koleksi 'mekanik'
          var mekanikDoc = await _firestore
              .collection('mekanik')
              .where('email', isEqualTo: email)
              .get();

          if (mekanikDoc.docs.isNotEmpty) {
            await _auth.signOut(); // Logout jika email terdaftar di mekanik
            return 'Login gagal: Akun ini terdaftar sebagai mekanik!';
          } else {
            return 'Login gagal: Email tidak ditemukan!';
          }
        }
      } else {
        return 'Login gagal: User tidak ditemukan!';
      }
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
}
