import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_mekanik_mobil.dart';

class MechanicListMobilScreen extends StatefulWidget {
  @override
  _MechanicListMobilScreenState createState() => _MechanicListMobilScreenState();
}

class _MechanicListMobilScreenState extends State<MechanicListMobilScreen> {
  List<Map<String, dynamic>> _filteredMechanics = [];
  List<Map<String, dynamic>> _mechanics = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  void _fetchMechanics() async {
    FirebaseFirestore.instance
        .collection('mekanik')
        .where('specialization', isEqualTo: 'Mobil') // Hanya spesialis mobil
        .get()
        .then((querySnapshot) {
      List<Map<String, dynamic>> mechanicsList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, 
          'name': doc['name'],
          'specialization': doc['specialization'],
          'rating': doc['rating'],
          'address': doc['address'],
          'image': doc['image'],
          'description': doc['description'],
          'price': doc['price'],
        };
      }).toList();
      
      setState(() {
        _mechanics = mechanicsList;
        _filteredMechanics = mechanicsList;
      });
    }).catchError((error) {
      print("Error fetching mechanics: $error");
    });
  }

  void _filterMechanics(String query) {
    final filtered = _mechanics.where((mechanic) {
      final name = mechanic['name'].toLowerCase();
      final specialization = mechanic['specialization'].toLowerCase();
      final address = mechanic['address'].toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input) || specialization.contains(input) || address.contains(input);
    }).toList();

    setState(() {
      _filteredMechanics = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cari Mekanik Mobil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari mekanik mobil...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterMechanics,
            ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredMechanics.isEmpty
                  ? Center(child: CircularProgressIndicator()) 
                  : ListView.builder(
                      itemCount: _filteredMechanics.length,
                      itemBuilder: (context, index) {
                        final mechanic = _filteredMechanics[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MechanicDetailMobilScreen(
                                  id: mechanic['id'],
                                  name: mechanic['name'],
                                  specialization: mechanic['specialization'],
                                  image: mechanic['image'],
                                  rating: mechanic['rating'],
                                  description: mechanic['description'],
                                  price: mechanic['price'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(mechanic['image']),
                                    radius: 40,
                                  ),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mechanic['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        mechanic['specialization'],
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        mechanic['address'],
                                        style: TextStyle(color: Colors.blueGrey),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            mechanic['rating'].toString(),
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
