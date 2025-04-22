import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'chat_screen.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  LatLng? userLocation;
  LatLng? mechanicLocation;
  String mechanicName = "Memuat...";
  String mechanicAddress = "Menghitung alamat...";
  String eta = "Menghitung...";
  String orderStatus = "Menunggu konfirmasi mekanik...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenOrderStatus();
  }

  void _listenOrderStatus() {
  FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots().listen((snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>? ?? {};
      setState(() {
        orderStatus = data['status']?.toString() ?? 'Menunggu konfirmasi mekanik...';
        isLoading = false; // Pastikan berhenti loading meskipun status belum "accepted"
      });

      if (orderStatus == "accepted") {
        _fetchData();
      } else if (orderStatus == "rejected") {
        _returnToOrderScreen();
      }
    }
  });
}

  void _returnToOrderScreen() {
    if (mounted) {
      setState(() {
        orderStatus = "Ditolak, cari mekanik lain...";
      });
    }
  }

  Future<void> _fetchData() async {
  try {
    DocumentSnapshot orderDoc = await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
    if (orderDoc.exists) {
      var data = orderDoc.data() as Map<String, dynamic>? ?? {};

      if (data['userLocation'] is GeoPoint) {
        GeoPoint userLoc = data['userLocation'];
        userLocation = LatLng(userLoc.latitude, userLoc.longitude);
      }

      if (data['mechanicLocation'] is GeoPoint) {
        GeoPoint mechLoc = data['mechanicLocation'];
        mechanicLocation = LatLng(mechLoc.latitude, mechLoc.longitude);
      }

      setState(() {
        isLoading = false;
      });

      if (userLocation != null && mechanicLocation != null) {
        _calculateEta();
      }
    }
  } catch (e) {
    print("Error mendapatkan data order: $e");
  }
}


  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error mendapatkan lokasi pengguna: $e");
    }
  }

  Future<void> _getMechanicData() async {
    try {
      DocumentSnapshot orderDoc = await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
      if (orderDoc.exists) {
        var data = orderDoc.data() as Map<String, dynamic>? ?? {};
        String mechanicId = data['mechanicId'] ?? '';
        DocumentSnapshot mechanicDoc = await FirebaseFirestore.instance.collection('mekanik').doc(mechanicId).get();

        if (mechanicDoc.exists) {
          var mechanicData = mechanicDoc.data() as Map<String, dynamic>? ?? {};
          setState(() {
            mechanicName = mechanicData['name']?.toString() ?? 'Nama tidak tersedia';
            if (mechanicData['location'] is GeoPoint) {
              GeoPoint location = mechanicData['location'];
              mechanicLocation = LatLng(location.latitude, location.longitude);
            }
          });
          if (mechanicLocation != null) {
            _getMechanicAddress();
          }
          if (userLocation != null && mechanicLocation != null) {
            _calculateEta();
          }
        }
      }
    } catch (e) {
      print("Error mendapatkan data mekanik: $e");
    }
  }

  Future<void> _getMechanicAddress() async {
    if (mechanicLocation == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        mechanicLocation!.latitude, mechanicLocation!.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          mechanicAddress = "${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}";
        });
      }
    } catch (e) {
      print("Error mendapatkan alamat mekanik: $e");
    }
  }

  void _calculateEta() {
    if (userLocation == null || mechanicLocation == null) return;
    final distance = Geolocator.distanceBetween(
      userLocation!.latitude, userLocation!.longitude,
      mechanicLocation!.latitude, mechanicLocation!.longitude,
    );
    final estimatedTime = (distance / 200).ceil();
    setState(() {
      eta = "$estimatedTime - ${estimatedTime + 5} menit";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (orderStatus == "accepted" || orderStatus == "on_the_way")
                  if (userLocation != null && mechanicLocation != null)
                    FlutterMap(
                      options: MapOptions(
                        center: LatLng(
                          (mechanicLocation!.latitude + userLocation!.latitude) / 2,
                          (mechanicLocation!.longitude + userLocation!.longitude) / 2,
                        ),
                        zoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [mechanicLocation!, userLocation!],
                              color: Colors.blue,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: mechanicLocation!,
                              builder: (ctx) => const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: userLocation!,
                              builder: (ctx) => const Icon(Icons.location_on, color: Colors.green, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.chat),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(), // Pass the orderId for chat context
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mechanicName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (mechanicAddress.isNotEmpty)
                          Text(mechanicAddress, style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(eta, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        if (orderStatus == "on_the_way")
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "Mekanik dalam perjalanan",
                              style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (orderStatus == "accepted")
                  Positioned(
                    top: 100,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Mekanik telah menerima pesanan",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                if (orderStatus == "rejected")
                  Positioned(
                    top: 100,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Pesanan ditolak, cari mekanik lain",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                if (orderStatus == "waiting" && !isLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Text(
                        "Menunggu konfirmasi dari mekanik...",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
