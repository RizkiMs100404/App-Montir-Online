import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  // Function to fetch mechanic and user names
  Future<String> getMechanicName(String mechanicId) async {
    try {
      final mechanicDoc = await FirebaseFirestore.instance
          .collection('mekanik')
          .doc(mechanicId)
          .get();
      if (mechanicDoc.exists) {
        return mechanicDoc['name'];
      } else {
        return 'Unknown Mechanic';
      }
    } catch (e) {
      print("Error fetching mechanic name: $e");
      return 'Error';
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['name'];
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Error';
    }
  }

  // Fetch history data and return it as a list
  Future<List<Map<String, dynamic>>> getHistoryData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get current user's uid
    if (userId == null) {
      print('User is not logged in');
      return [];
    }
    
    final ordersCollection = FirebaseFirestore.instance.collection('orders');
    try {
      final querySnapshot = await ordersCollection
          .where('userId', isEqualTo: userId) // Filter by current userId
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No orders found for userId $userId');
      }

      List<Map<String, dynamic>> historyData = [];
      for (var doc in querySnapshot.docs) {
        final mechanicName = await getMechanicName(doc['mechanicId']);
        final userName = await getUserName(doc['userId']);

        historyData.add({
          'mechanic': mechanicName,
          'user': userName,
          'service': doc['specialization'],
          'price': 'Rp ${doc['price']}',
          'date': doc['createdAt'].toDate().toString(),
        });
      }

      return historyData;
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Layanan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getHistoryData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching data. Please try again later.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            final historyData = snapshot.data ?? [];

            return historyData.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada riwayat layanan',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final history = historyData[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.blueAccent,
                                    child: Icon(
                                      Icons.build,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          history['mechanic'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          history['user'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                history['service'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    history['price'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tanggal: ${history['date']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
