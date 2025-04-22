import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pendapatan_mekanik.dart';
import 'pesan_mekanik.dart';
import 'profile_mekanik.dart';
import 'order_mekanik.dart';

class MechanicHomeScreen extends StatefulWidget {
  @override
  _MechanicHomeScreenState createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  String mechanicName = "";
  String weatherInfo = "Loading...";
  int _selectedIndex = 0;
  int orderMasuk = 0;
  int dalamPerjalanan = 0;
  int selesai = 0;
  String mechanicImage = '';
  double mechanicRating = 0;
  String? mechanicId;

  @override
  void initState() {
    super.initState();
    _fetchMechanicData();
  }

  Future<void> _fetchMechanicData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot mechanicSnapshot =
          await FirebaseFirestore.instance.collection('mekanik').doc(user.uid).get();

      setState(() {
        mechanicId = user.uid;
        mechanicName = mechanicSnapshot['name'] ?? "Mekanik";
        mechanicImage = mechanicSnapshot['image'] != null && mechanicSnapshot['image'] != ""
            ? mechanicSnapshot['image']
            : "assets/icons/profile.jpg";
        mechanicRating = mechanicSnapshot['rating'] ?? 0.0;
      });

      _fetchWeatherData();
      _fetchOrderData();
      _listenForNewOrders();
    }
  }

  Future<void> _fetchWeatherData() async {
  try {
    String apiKey = "bb7eca72e5ec8bfc713a290a65c29117";
    String city = "Garut"; 

    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=id"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weatherInfo = "${data['main']['temp']}°C, ${data['weather'][0]['description']}";
      });
    } else {
      setState(() {
        weatherInfo = "Gagal mengambil data cuaca";
      });
    }
  } catch (e) {
    setState(() {
      weatherInfo = "Error mengambil data cuaca";
    });
  }
}

  Future<void> _fetchOrderData() async {
    if (mechanicId == null) return;

    QuerySnapshot orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('mechanicId', isEqualTo: mechanicId)
        .get();

    setState(() {
      orderMasuk = orders.docs.where((doc) => doc['status'] == 'pending').length;
      dalamPerjalanan = orders.docs.where((doc) => doc['status'] == 'on_the_way').length;
      selesai = orders.docs.where((doc) => doc['status'] == 'completed').length;
    });
  }

  void _listenForNewOrders() {
    if (mechanicId == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('mechanicId', isEqualTo: mechanicId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        orderMasuk = snapshot.docs.where((doc) => doc['status'] == 'pending').length;
        dalamPerjalanan = snapshot.docs.where((doc) => doc['status'] == 'on_the_way').length;
        selesai = snapshot.docs.where((doc) => doc['status'] == 'completed').length;
      });
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MechanicHomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MechanicOrderScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MechanicChatScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue,
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hai, $mechanicName",
                                style: GoogleFonts.poppins(
                                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow, size: 20),
                                Text("$mechanicRating", style: GoogleFonts.poppins(color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(weatherInfo, style: GoogleFonts.poppins(color: Colors.white)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MechanicProfileScreen()),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(mechanicImage),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MechanicEarningsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Lihat Pendapatan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("Ringkasan Orderan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildSummaryCard("Order Masuk", "$orderMasuk")),
                  Expanded(child: _buildSummaryCard("Dalam Perjalanan", "$dalamPerjalanan")),
                  Expanded(child: _buildSummaryCard("Selesai", "$selesai")),
                ],
              ),
              SizedBox(height: 20),
              Text("Foto & Rating Mekanik", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Card(
  elevation: 6,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  color: Colors.white,
  child: Container(
    width: double.infinity, 
    padding: EdgeInsets.all(16.0),
    child: Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(mechanicImage),
        ),
        SizedBox(height: 10),
        Text(
          "Rating: $mechanicRating",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    ),
  ),
),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Order"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
  Widget _buildSummaryCard(String title, String count) {
  return Card(
    elevation: 6, // Menambah shadow
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(count, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    ),
  );
}
}
