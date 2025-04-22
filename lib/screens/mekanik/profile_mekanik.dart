import 'package:app_montir/cover_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class MechanicProfileScreen extends StatefulWidget {
  @override
  _MechanicProfileScreenState createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  String _specialization = 'Motor'; // Default value for specialization

  @override
  void initState() {
    super.initState();
    _fetchMechanicData();
  }

  Future<void> _fetchMechanicData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('mekanik')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          setState(() {
            _nameController.text = snapshot['name'] ?? '';
            _specialization =
                snapshot['specialization'] ?? 'Motor'; // Set specialization
            _addressController.text = snapshot['address'] ?? '';
            _descriptionController.text = snapshot['description'] ?? '';
            _priceController.text = snapshot['price'] ?? '';
            _emailController.text = snapshot['email'] ?? '';
            _phoneController.text = snapshot['phone'] ?? '';
            _imageUrl = snapshot['image'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  Widget _buildProfileField(
      String label, IconData icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('mekanik')
            .doc(user.uid)
            .set({
          'name': _nameController.text,
          'specialization': _specialization,
          'address': _addressController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'image': _selectedImage != null ? _selectedImage!.path : _imageUrl,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil berhasil diperbarui')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CoverScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Mekanik',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : AssetImage('assets/icons/profile.jpg'))
                            as ImageProvider,
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildProfileField("Nama Lengkap", Icons.person, _nameController),
            // Dropdown for specialization
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: DropdownButtonFormField<String>(
                value: _specialization,
                decoration: InputDecoration(
                  labelText: 'Spesialisasi',
                  prefixIcon: Icon(Icons.build),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                items: [
                  DropdownMenuItem(child: Text('Motor'), value: 'Motor'),
                  DropdownMenuItem(child: Text('Mobil'), value: 'Mobil'),
                ],
                onChanged: (value) {
                  setState(() {
                    _specialization = value!;
                  });
                },
              ),
            ),
            _buildProfileField("Alamat", Icons.home, _addressController),
            _buildProfileField(
                "Deskripsi", Icons.description, _descriptionController),
            _buildProfileField(
                "Harga Jasa", Icons.attach_money, _priceController,
                keyboardType: TextInputType.number),
            _buildProfileField("Email", Icons.email, _emailController,
                enabled: false),
            _buildProfileField("Nomor HP", Icons.phone, _phoneController,
                keyboardType: TextInputType.phone),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text("Simpan Perubahan",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _logout,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text("Logout",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
