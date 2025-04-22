import 'package:app_montir/cover_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  File? _selectedImage;
  // ignore: unused_field
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email;
          _emailController.text = user.email ?? '';
        });

        final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            _nameController.text = snapshot['name'] ?? '';
            _phoneController.text = snapshot['phone'] ?? '';
            _addressController.text = snapshot['address'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CoverScreen()), 
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : const AssetImage('assets/icons/profile.jpg') as ImageProvider,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProfileField("Nama Lengkap", Icons.person, _nameController),
            _buildProfileField("Email", Icons.email, _emailController, enabled: false),
            _buildPasswordField("Password", Icons.lock, _passwordController),
            _buildProfileField("Nomor HP", Icons.phone, _phoneController, keyboardType: TextInputType.phone),
            _buildProfileField("Alamat Lengkap", Icons.home, _addressController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Keluar", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, IconData icon, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: _togglePasswordVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
