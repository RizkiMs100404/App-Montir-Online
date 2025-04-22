import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '/../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService(); 

  bool _isLoading = false;
   bool _isPasswordVisible = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? error = await _userService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Remember me and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (value) {},
                              activeColor: Colors.blue,
                            ),
                            const Text(
                              "Ingatkan Saya",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Lupa Password?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Sign in button
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
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Login",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // "Sign in with" text with lines
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
                            "Login Dengan",
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
                    const SizedBox(height: 30),
                    // Don't have an account? Sign up
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Tidak Punya Akun? ",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Daftar",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
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
