import 'package:app_montir/models/mekanik_model.dart';
import 'package:app_montir/services/mekanik_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class RegisterMekanikScreen extends StatefulWidget {
  @override
  _RegisterMekanikScreenState createState() => _RegisterMekanikScreenState();
}

class _RegisterMekanikScreenState extends State<RegisterMekanikScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String specialization = 'Motor';
  bool _isPasswordVisible = false;

  final MekanikService mekanikService = MekanikService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Bergabung Menjadi Mekanik',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Isi data lengkap Anda untuk bergabung menjadi mekanik Montir Online dan dapatkan lebih banyak pelanggan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            _buildTextField(nameController, 'Nama Lengkap', Icons.person),
            _buildTextField(emailController, 'Email', Icons.email),
            _buildTextField(phoneController, 'Nomor Telepon', Icons.phone),
            _buildTextField(addressController, 'Alamat', Icons.home),
            _buildDropdownField(),
            _buildPasswordField(),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    Mekanik mekanik = Mekanik(
                      id: '',
                      name: nameController.text,
                      specialization: specialization,
                      rating: 0.0,
                      address: addressController.text,
                      location: 'Default Location',
                      image: 'https://example.com/default-image.jpg',
                      description: 'Mekanik profesional',
                      price: '0',
                      availability: true,
                      email: emailController.text,
                      phone: phoneController.text,
                    );
                    await mekanikService.registerMekanik(
                      email: emailController.text,
                      password: passwordController.text,
                      mekanik: mekanik,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registrasi berhasil!')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginMekanikScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Daftar',
                  style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginMekanikScreen()),
                  );
                },
                child: Text(
                  'Sudah punya akun? Login',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [bool obscureText = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: GoogleFonts.poppins(),
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

  Widget _buildDropdownField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Spesialisasi',
          labelStyle: GoogleFonts.poppins(),
          prefixIcon: Icon(Icons.build, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: specialization,
            isExpanded: true,
            style: GoogleFonts.poppins(color: Colors.black),
            items: ['Motor', 'Mobil'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                specialization = newValue!;
              });
            },
          ),
        ),
      ),
    );
  }
}
