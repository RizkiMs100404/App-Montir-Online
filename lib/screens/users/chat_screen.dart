import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_chat.dart';
import 'home_screen.dart';
import 'order_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _currentIndex = 2;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderScreen(
            userId: "", 
            mechanicId: "",
            specialization: "",
            price: "",
            image: "", 
            mechanicData: {},
        )),
        );
        break;
      case 2:
        // Stay on ChatScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentUser == null
          ? const Center(child: Text("User tidak ditemukan"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('mekanik').snapshots(),
              builder: (context, mekanikSnapshot) {
                if (mekanikSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!mekanikSnapshot.hasData || mekanikSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada mekanik.'));
                }

                var mekanikList = mekanikSnapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: mekanikList.length,
                  itemBuilder: (context, index) {
                    var mekanikData = mekanikList[index];
                    String mekanikId = mekanikData.id;
                    String name = mekanikData['name'] ?? "Mekanik";

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .where('userId', isEqualTo: _currentUser!.uid)
                          .where('mekanikId', isEqualTo: mekanikId)
                          .snapshots(),
                      builder: (context, chatSnapshot) {
                        String lastMessage = "Belum ada chat";
                        DateTime? lastTime;
                        int unreadCount = 0;
                        String? chatId;

                        if (chatSnapshot.hasData && chatSnapshot.data!.docs.isNotEmpty) {
                          var chatData = chatSnapshot.data!.docs.first;
                          lastMessage = chatData['lastMessage'] ?? "Pesan terakhir...";
                          Timestamp? lastTimestamp = chatData['lastTimestamp'];
                          unreadCount = (chatData['unreadCount'] ?? 0).toInt();
                          chatId = chatData.id;

                          if (lastTimestamp != null) {
                            lastTime = lastTimestamp.toDate();
                          }
                        }

                        return GestureDetector(
                          onTap: () async {
                            if (chatId == null) {
                              var newChatDoc = await FirebaseFirestore.instance.collection('chats').add({
                                'userId': _currentUser!.uid,
                                'mekanikId': mekanikId,
                                'lastMessage': 'Belum ada pesan',
                                'lastTimestamp': FieldValue.serverTimestamp(),
                                'unreadCount': 0,
                              });

                              chatId = newChatDoc.id;
                              lastMessage = 'Belum ada pesan';

                              await FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .collection('messages')
                                  .add({
                                    'senderId': _currentUser!.uid,
                                    'receiverId': mekanikId,
                                    'message': 'Halo, saya ingin bertanya.',
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });
                            } else {
                              await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
                                'unreadCount': 0,
                              });
                            }

                            // Navigasi ke ChatDetailScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  mekanikId: mekanikId,
                                  name: name,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade800,
                                  radius: 24,
                                  child: Text(
                                    name.isNotEmpty ? name[0] : "M",
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lastMessage,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      lastTime != null
                                          ? "${lastTime.hour}:${lastTime.minute.toString().padLeft(2, '0')}"
                                          : "--:--",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 6),
                                    if (unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
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
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
