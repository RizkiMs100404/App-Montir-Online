import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'mekanik_mobil.dart';
import 'mekanik_motor.dart';
import 'order_screen.dart';
import 'daftar_harga_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _userName = userDoc['name'] ?? 'Pengguna';
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hai, ${_userName ?? 'Loading...'}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/icons/profile.jpg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Carilah montir terbaikmu di sini',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CarouselSlider(
  options: CarouselOptions(
    height: 180,
    viewportFraction: 1.0, // Menggunakan lebar penuh
    enableInfiniteScroll: true,
    enlargeCenterPage: true,
  ),
  items: [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ].map((imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(
        imagePath,
        fit: BoxFit.fitWidth, // Pastikan gambar menyesuaikan lebar layar tanpa terpotong
        width: double.infinity,
      ),
    );
  }).toList(),
),

                ],
              ),
            ),

            // Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildServiceButton('Motor', 'assets/icons/fitur1.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MechanicListScreen()),
                    );
                  }),
                  _buildServiceButton('Mobil', 'assets/icons/fitur2.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MechanicListMobilScreen()),
                    );
                  }),
                  _buildServiceButton('Price List', 'assets/icons/fitur3.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DaftarHargaScreen()),
                    );
                  }),
                  _buildServiceButton('History', 'assets/icons/fitur4.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryScreen()),
                    );
                  }),
                ],
              ),
            ),

            // News Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berita Otomotif',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildNewsItem('assets/images/mesin.jpg',
                      'Pelajari cara memilih bengkel terpercaya dengan layanan profesional.'),
                  _buildNewsItem('assets/images/oli.jpg',
                      'Dapatkan diskon hingga 20% untuk semua jenis servis motor.'),
                  _buildNewsItem('assets/images/rem.jpg',
                      'Ketahui pentingnya servis berkala agar motor tetap prima.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
              switch (index) {
                case 1:
                  return OrderScreen(
                    userId: "", 
                    mechanicId: "",
                    specialization: "",
                    price: "",
                    image: "", 
                    mechanicData: {},
                  );
                case 2:
                  return const ChatScreen();
                default:
                  return const HomeScreen();
              }
            }),
            (route) => false,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(String label, String imagePath, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent, // Removed border radius
            child: Image.asset(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String imagePath, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
