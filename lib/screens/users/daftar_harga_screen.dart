import 'package:flutter/material.dart';

class DaftarHargaScreen extends StatefulWidget {
  const DaftarHargaScreen({super.key});

  @override
  _DaftarHargaScreenState createState() => _DaftarHargaScreenState();
}

class _DaftarHargaScreenState extends State<DaftarHargaScreen> {
  final List<Map<String, String>> layanan = [
    {
      'title': 'Servis Mesin',
      'price': 'Rp 500.000',
      'image': 'assets/images/mesin.jpg'
    },
    {
      'title': 'Ganti Oli',
      'price': 'Rp 100.000',
      'image': 'assets/images/oli.jpg'
    },
    {
      'title': 'Perbaikan Rem',
      'price': 'Rp 300.000',
      'image': 'assets/images/rem.jpg'
    },
    {
      'title': 'Penggantian Aki',
      'price': 'Rp 700.000',
      'image': 'assets/images/aki.jpg'
    },
    {
      'title': 'Tune Up',
      'price': 'Rp 250.000',
      'image': 'assets/images/tune.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estimasi Harga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: layanan.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Aksi saat item ditekan (misal membuka detail)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Detail Layanan'),
                    content: Text(
                      'Anda memilih: ${layanan[index]['title']} dengan harga ${layanan[index]['price']}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Image.asset(
                        layanan[index]['image']!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              layanan[index]['title']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              layanan[index]['price']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
