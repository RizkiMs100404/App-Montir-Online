import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:slider_button/slider_button.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? orderData;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get();
    if (orderSnapshot.exists) {
      Map<String, dynamic> data = orderSnapshot.data() as Map<String, dynamic>;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'])
          .get();

      setState(() {
        orderData = data;
        userName = userSnapshot.exists ? userSnapshot['name'] : 'Unknown User';
      });
    }
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      return placemarks.isNotEmpty
          ? "${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}"
          : "Unknown Location";
    } catch (e) {
      return "Unknown Location";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        centerTitle: true,
      ),
      body: orderData == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<String>(
              future: _getAddress(orderData!['userLocation'].latitude,
                  orderData!['userLocation'].longitude),
              builder: (context, userAddressSnapshot) {
                final userAddress =
                    userAddressSnapshot.data ?? "Fetching address...";
                GeoPoint mechanicLocationGeoPoint =
                    orderData!['mechanicLocation'];
                LatLng mechanicLocation = LatLng(
                    mechanicLocationGeoPoint.latitude,
                    mechanicLocationGeoPoint.longitude);

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      _buildInfoCard("Name: $userName", userAddress),
                      SizedBox(height: 20),
                      _buildMap(userAddress, mechanicLocation),
                      SizedBox(height: 20),
                      if (orderData!['status'] == 'accepted')
                        _buildSwipeButton(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(subtitle, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(String userAddress, LatLng mechanicLocation) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(orderData!['userLocation'].latitude,
              orderData!['userLocation'].longitude),
          zoom: 13.0,
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
                point: LatLng(orderData!['userLocation'].latitude,
                    orderData!['userLocation'].longitude),
                builder: (ctx) =>
                    Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
              Marker(
                width: 40.0,
                height: 40.0,
                point: mechanicLocation,
                builder: (ctx) =>
                    Icon(Icons.location_pin, color: Colors.blue, size: 40),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  LatLng(orderData!['userLocation'].latitude,
                      orderData!['userLocation'].longitude),
                  mechanicLocation,
                ],
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeButton() {
    return SliderButton(
      action: () async {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .update({'status': 'on_the_way'});

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Status diperbarui ke 'Dalam Perjalanan'"),
          backgroundColor: Colors.green,
        ));
      },
      label: Text(
        "Geser untuk Dalam Perjalanan",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      icon: Icon(Icons.motorcycle, color: Colors.white),
      width: MediaQuery.of(context).size.width * 0.9,
      height: 70, // Pastikan lebih besar dari buttonSize
      buttonSize: 60, // Harus lebih kecil atau sama dengan height
      buttonColor: Colors.blue,
      backgroundColor: Colors.grey[300]!,
      baseColor: Colors.white,
    );
  }
}
