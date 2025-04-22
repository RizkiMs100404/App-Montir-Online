import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bubble.dart';

class ChatMechanicDetailScreen extends StatefulWidget {
  final String userId;
  final String name;

  const ChatMechanicDetailScreen({super.key, required this.userId, required this.name});

  @override
  _ChatMechanicDetailScreenState createState() => _ChatMechanicDetailScreenState();
}

class _ChatMechanicDetailScreenState extends State<ChatMechanicDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentMechanic = FirebaseAuth.instance.currentUser;

  String getChatId() {
    if (_currentMechanic == null) return "";
    List<String> ids = [_currentMechanic!.uid, widget.userId];
    ids.sort(); // Pastikan urutan konsisten
    return ids.join("_");
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _currentMechanic == null) return;

    String chatId = getChatId();
    if (chatId.isEmpty) return;

    FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'senderId': _currentMechanic!.uid,
      'receiverId': widget.userId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'mekanikId': _currentMechanic!.uid,
      'userId': widget.userId,
      'lastMessage': _messageController.text.trim(),
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
    
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId();
    if (chatId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: Center(child: Text("Gagal memuat chat")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.name, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada pesan"));
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isSender = message['senderId'] == _currentMechanic!.uid;
                    DateTime? timestamp;
                    if (message['timestamp'] != null) {
                      timestamp = (message['timestamp'] as Timestamp).toDate();
                    }
                    return ChatBubble(
                      text: message['message'],
                      isSender: isSender,
                      timestamp: timestamp,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue.shade900,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
