import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'status_order.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> mechanicData;
  final String orderId;
  final String userId;
  final double userLatitude;
  final double userLongitude;
  final String? price;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.mechanicData,
    required this.userId,
    required this.userLatitude,
    required this.userLongitude,
    required this.price,
  });

  @override
  _OrderConfirmationScreenState createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  double mechanicPrice = 0;
  double dpPrice = 0;
  String? selectedPaymentMethod;
  String userAddress = "Sedang mengambil lokasi...";

  @override
  void initState() {
    super.initState();
    print("Data mekanik: ${widget.mechanicData}");
    _getAddressFromGeoPoint(widget.userLatitude, widget.userLongitude);
    _initializePrices();
  }

  Future<void> _getAddressFromGeoPoint(double latitude, double longitude) async {
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

  void _initializePrices() {
    setState(() {
      mechanicPrice = _parsePrice(widget.price);
      dpPrice = mechanicPrice * 0.5; // DP 50% dari harga mekanik
    });
    print("Harga mekanik: $mechanicPrice");
  }

  double _parsePrice(String? price) {
    if (price == null) return 0;
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 3).format(amount);
  }

  Future<void> _cancelOrder() async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan dibatalkan')));
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membatalkan pesanan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detail Mekanik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(widget.mechanicData['image'] ?? 'https://via.placeholder.com/60'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.mechanicData['name'] ?? 'Nama Mekanik',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(widget.mechanicData['specialization'] ?? 'Spesialisasi',
                            style: const TextStyle(color: Colors.grey)),
                        Text(formatCurrency(mechanicPrice),
                            style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Alamat Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home, color: Colors.blueAccent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lokasi Anda'),
                          Text(userAddress, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile(
                    value: 'DP via Transfer Bank',
                    groupValue: selectedPaymentMethod,
                    title: const Text('DP via Transfer Bank'),
                    subtitle: Text('DP ${formatCurrency(dpPrice)}'),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    value: 'DP via E-Wallet',
                    groupValue: selectedPaymentMethod,
                    title: const Text('DP via E-Wallet'),
                    subtitle: Text('DP ${formatCurrency(dpPrice)}'),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedPaymentMethod == null
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderStatusScreen(orderId: widget.orderId ?? ''),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lanjutkan Pesanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal Pesanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
