import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginMekanikScreen extends StatefulWidget {
  @override
  _LoginMekanikScreenState createState() => _LoginMekanikScreenState();
}

class _LoginMekanikScreenState extends State<LoginMekanikScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    try {
      // 1. Login dengan FirebaseAuth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // 2. Cek apakah email ada di koleksi mekanik
        QuerySnapshot mekanikQuery = await _firestore
            .collection('mekanik')
            .where('email', isEqualTo: emailController.text.trim())
            .get();

        if (mekanikQuery.docs.isNotEmpty) {
          // 3. Jika ditemukan, sukses login sebagai mekanik
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login berhasil, selamat datang mekanik!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MechanicHomeScreen()),
          );
        } else {
          // 4. Jika tidak ditemukan, logout dan tampilkan error
          await _auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Akun ini bukan mekanik. Silakan login dengan akun mekanik.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Masukkan email dan password Anda untuk melanjutkan.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            _buildPasswordField(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterMekanikScreen()),
                );
              },
              child: Text(
                'Belum punya akun? Daftar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }
}
