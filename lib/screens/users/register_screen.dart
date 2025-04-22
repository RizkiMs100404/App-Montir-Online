import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/../services/user_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); 
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String fullName = _fullNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String phone = _phoneController.text;

      if (fullName.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tolong Isi Data Dengan Benar.')),
        );
        return;
      }

      String? error = await _userService.registerUser(
        email: email,
        password: password,
        name: fullName,
        phone: phone, // Pass phone number to the service
      );

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Form container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.83,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Isi Data Berikut",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Full Name field
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.person, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Email field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Phone field
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Nomor Telepon",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Daftar",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // "Sign up with" text with lines
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Daftar Dengan",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Social media icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/fb.png',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 20),
                        Image.asset(
                          'assets/icons/twitter.png',
                          width: 45,
                          height: 45,
                        ),
                        const SizedBox(width: 20),
                        Image.asset(
                          'assets/icons/google.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 20),
                        Image.asset(
                          'assets/icons/github.png',
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Sudah Punya Akun? ",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
