import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 
import 'konfirmasi_order.dart';
import 'home_screen.dart';
import 'chat_screen.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, dynamic>? mechanicData;
  final String userId;
  final String mechanicId;
  final String specialization;
  final String price;
  final String image;

  const OrderScreen({
    Key? key,
    required this.mechanicData,
    required this.userId,
    required this.mechanicId, 
    required this.specialization,
    required this.price,
    required this.image,
  }) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  LatLng? _currentLocation;
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  String userAddress = "Sedang mengambil lokasi...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    await _saveUserLocation(position.latitude, position.longitude);
    _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _saveUserLocation(double lat, double lng) async {
    if (currentUserId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'location': GeoPoint(lat, lng),
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          userAddress = "${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      setState(() {
        userAddress = "Gagal mengambil alamat.";
      });
    }
  }

  Future<void> _saveOrder() async {
    // Ensure mechanic data is selected
    if (widget.mechanicData == null || widget.specialization == 'default' || widget.price == 'Rp. 0') {
      _showMechanicSelectionAlert(); // Show alert if mechanic is not selected
      return;
    }

    // Proceed with order if mechanic is selected
    if (_currentLocation == null) return;

    DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'userId': currentUserId,
      'mechanicId': widget.mechanicId, 
      'specialization': widget.specialization,
      'price': widget.price,
      'image': widget.image,
      'userLocation': GeoPoint(_currentLocation!.latitude, _currentLocation!.longitude),
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    String orderId = orderRef.id;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          orderId: orderId,
          mechanicData: widget.mechanicData!,
          userId: widget.userId,
          userLatitude: _currentLocation!.latitude,
          userLongitude: _currentLocation!.longitude,
          price: widget.price,
        ),
      ),
    );
  }

  void _showMechanicSelectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Mekanik'),
          content: const Text('Anda harus memilih mekanik terlebih dahulu sebelum melakukan pemesanan.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Ensure mechanic is selected before navigating to OrderScreen
        if (widget.mechanicData == null || widget.specialization == 'default' || widget.price == 'Rp. 0') {
          _showMechanicSelectionAlert();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget),
          );
        }
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentLocation != null
              ? FlutterMap(
                  options: MapOptions(
                    center: _currentLocation,
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
                          width: 80.0,
                          height: 80.0,
                          point: _currentLocation!,
                          builder: (ctx) => const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.mechanicData?['name'] ?? "", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(widget.specialization, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("${widget.price}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
  onPressed: (widget.mechanicData != null && widget.mechanicId.isNotEmpty && widget.price != 'Rp. 0') 
      ? _saveOrder 
      : null,
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    backgroundColor: (widget.mechanicData != null && widget.mechanicId.isNotEmpty && widget.price != 'Rp. 0') 
        ? Colors.blue 
        : Colors.grey, // Warna tombol berubah jika tidak bisa ditekan
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: const Size(double.infinity, 48),
  ),
  child: const Text('Order Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
),

                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Order'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}
