import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MechanicEarningsScreen extends StatefulWidget {
  @override
  _MechanicEarningsScreenState createState() => _MechanicEarningsScreenState();
}

class _MechanicEarningsScreenState extends State<MechanicEarningsScreen> {
  double totalEarnings = 0.0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchEarningsData();
  }

  Future<void> _fetchEarningsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('mechanicId', isEqualTo: user.uid)
          .get();

      double earnings = 0.0;
      List<Map<String, dynamic>> transactionList = [];

      for (var doc in ordersSnapshot.docs) {
        String priceStr = doc['price'] ?? '0';
        String extractedPrice = priceStr.split('/')[0].replaceAll('.', '');
        double price = double.tryParse(extractedPrice) ?? 0.0;
        earnings += price;

        // Fetch user name using the userId from the order
        String userId = doc['userId'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        String userName = userDoc.exists ? userDoc['name'] ?? 'Unknown User' : 'Unknown User';

        // Get createdAt field
        Timestamp createdAtTimestamp = doc['createdAt'] ?? Timestamp.now();
        String createdAt = _formatDate(createdAtTimestamp);

        transactionList.add({
          'specialization': doc['specialization'] ?? 'Unknown Specialization',
          'price': price,
          'createdAt': createdAt,
          'userName': userName,
        });
      }

      setState(() {
        totalEarnings = earnings;
        transactions = transactionList;
      });
    }
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
        RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pendapatan Mekanik", style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("Total:", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Rp ${_formatPrice(totalEarnings)}",
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Riwayat Transaksi", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: transactions.isEmpty
                  ? Center(child: Text("Belum ada transaksi", style: GoogleFonts.poppins()))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(transactions[index]['specialization'], style: GoogleFonts.poppins()),
                            subtitle: Text('${transactions[index]['userName']} - ${transactions[index]['createdAt']}',
                                style: GoogleFonts.poppins(fontSize: 12)),
                            trailing: Text("Rp ${_formatPrice(transactions[index]['price'])}",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
