import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'detail_order.dart';
import 'home_screen.dart';
import 'pesan_mekanik.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicOrderScreen extends StatefulWidget {
  const MechanicOrderScreen({Key? key}) : super(key: key);

  @override
  _MechanicOrderScreenState createState() => _MechanicOrderScreenState();
}

class _MechanicOrderScreenState extends State<MechanicOrderScreen> {
  int _selectedIndex = 1;

  // Ambil order yang statusnya 'pending' dan mechanicId sesuai dengan user yang sedang login
  Stream<List<Map<String, dynamic>>> _fetchOrders() {
    return FirebaseFirestore.instance.collection('orders')
        .where('mechanicId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Filter berdasarkan mechanicId
        .where('status', isEqualTo: 'pending') // Hanya ambil order dengan status pending
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              'userId': doc['userId'],
              'specialization': doc['specialization'],
              'status': doc['status'],
              'userLocation': doc['userLocation'],
              'mechanicId': doc['mechanicId'],
            }).toList());
  }

  // Menangani penerimaan order
  Future<void> _acceptOrder(String orderId) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    GeoPoint mechanicLocation = GeoPoint(position.latitude, position.longitude);

    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'accepted',
      'mechanicId': FirebaseAuth.instance.currentUser?.uid, // Menyimpan mechanicId yang menerima order
      'mechanicLocation': mechanicLocation,
      'updatedAt': Timestamp.now(), // Tambahkan waktu update
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailScreen(orderId: orderId)),
    );
  }

  // Menangani penolakan order
  void _rejectOrder(String orderId) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'rejected',
      'mechanicId': FieldValue.delete(), // Menghapus mechanicId jika order ditolak
      'mechanicLocation': FieldValue.delete(),
      'updatedAt': Timestamp.now(), // Tambahkan waktu update
    });
  }

  // Mengambil nama user berdasarkan userId
  Future<String> _getUserName(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? doc['name'] : 'Unknown User';
  }

  // Mengambil alamat berdasarkan koordinat latitude dan longitude
  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      return placemarks.isNotEmpty ? "${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}" : "Unknown Location";
    } catch (e) {
      return "Unknown Location";
    }
  }

  // Mengubah halaman berdasarkan index yang dipilih
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MechanicHomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MechanicOrderScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MechanicChatScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>( 
        stream: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No pending orders', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return FutureBuilder<String>(
                future: _getUserName(order['userId']),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return Center(child: CircularProgressIndicator());
                  final userName = userSnapshot.data ?? 'Unknown User';

                  return FutureBuilder<String>(
                    future: _getAddress(order['userLocation'].latitude, order['userLocation'].longitude),
                    builder: (context, addressSnapshot) {
                      final userAddress = addressSnapshot.data ?? "Fetching address...";

                      return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 5,
    shadowColor: Colors.blue.withOpacity(0.2),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade400,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order['specialization'],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade600, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  userAddress.isNotEmpty ? userAddress : "Unknown Location",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(order['userLocation'].latitude, order['userLocation'].longitude),
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(order['userLocation'].latitude, order['userLocation'].longitude),
                        builder: (ctx) => Icon(Icons.location_pin, color: Colors.blue.shade900, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _rejectOrder(order['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 4,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.close, size: 18),
                    SizedBox(width: 5),
                    Text("Reject", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _acceptOrder(order['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 4,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 5),
                    Text("Accept", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);



                    },
                  );
                },
              );
            },
          );
        },
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
}
