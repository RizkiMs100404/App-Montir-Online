import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'order_screen.dart';

class MechanicDetailMobilScreen extends StatefulWidget {
  final String id;
  final String name;
  final String specialization;
  final String image;
  final double rating;
  final String description;
  final String price;

  const MechanicDetailMobilScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.specialization,
    required this.image,
    required this.rating,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  _MechanicDetailMobilScreenState createState() => _MechanicDetailMobilScreenState();
}

class _MechanicDetailMobilScreenState extends State<MechanicDetailMobilScreen> {
  int selectedIndex = 0;
  final TextEditingController reviewController = TextEditingController();
  double selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Mekanik',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.specialization,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          widget.rating.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTabButton("Deskripsi", 0),
                        _buildTabButton("Review", 1),
                      ],
                    ),
                    const SizedBox(height: 12),
                    selectedIndex == 0 ? _buildDescription() : _buildReviewSection(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rp. ${widget.price}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _handleOrder,
                    child: const Text('Pesan', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selectedIndex == index ? Colors.blue : Colors.grey[200],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: selectedIndex == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(widget.description, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Beri Ulasan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: reviewController,
          decoration: InputDecoration(
            hintText: "Tulis ulasan...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                Icons.star,
                size: 30,
                color: index < selectedRating ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedRating = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  void _handleOrder() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil user ID!')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
          mechanicData: {
            'id': widget.id,
            'name': widget.name,
            'specialization': widget.specialization,
            'image': widget.image,
            'rating': widget.rating,
            'description': widget.description,
            'price': widget.price,
          },
          userId: userId,
          mechanicId: widget.id,
          specialization: widget.specialization,
          price: widget.price,
          image: widget.image,
        ),
      ),
    );
  }
}
