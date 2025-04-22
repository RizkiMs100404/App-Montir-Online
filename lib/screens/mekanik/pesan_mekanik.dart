import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_mekanik_detail.dart';
import 'home_screen.dart';
import 'order_mekanik.dart';

class MechanicChatScreen extends StatefulWidget {
  const MechanicChatScreen({super.key});

  @override
  _MechanicChatScreenState createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  final User? _currentMechanic = FirebaseAuth.instance.currentUser;
  int _currentIndex = 2; // Indeks awal di Chat

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MechanicHomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MechanicOrderScreen()),
        );
        break;
      case 2:
        // Tetap di ChatScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentMechanic == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('mekanikId', isEqualTo: _currentMechanic!.uid)
                  .orderBy('lastTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada chat.'));
                }

                var chatList = snapshot.data!.docs;
                Set<String> displayedUsers = {}; // Hindari duplikasi

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    var chat = chatList[index];
                    String userId = chat['userId'];

                    // Skip jika userId sudah ada di daftar yang ditampilkan
                    if (displayedUsers.contains(userId)) {
                      return const SizedBox.shrink();
                    }
                    displayedUsers.add(userId);

                    String lastMessage = chat['lastMessage'] ?? "Pesan terakhir...";
                    Timestamp? lastTimestamp = chat['lastTimestamp'];
                    int unreadCount = (chat['unreadCount'] ?? 0).toInt();

                    DateTime? lastTime;
                    if (lastTimestamp != null) {
                      lastTime = lastTimestamp.toDate();
                    }

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return Container();
                        }

                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return Container(); // Hindari error jika user tidak ditemukan
                        }

                        var userData = userSnapshot.data!;
                        String userName = userData['name'] ?? "User";

                        return GestureDetector(
                          onTap: () async {
                            // Reset unread count ketika chat dibuka
                            await FirebaseFirestore.instance.collection('chats').doc(chat.id).update({
                              'unreadCount': 0,
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatMechanicDetailScreen(
                                  userId: userId,
                                  name: userName,
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
                                    userName.isNotEmpty ? userName[0] : "U",
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
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
