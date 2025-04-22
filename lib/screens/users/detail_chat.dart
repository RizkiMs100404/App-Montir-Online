import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String mekanikId;
  final String name;

  const ChatDetailScreen({super.key, required this.mekanikId, required this.name});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late String chatId;

  @override
  void initState() {
    super.initState();
    _generateChatId();
  }

  // Membuat chatId unik berdasarkan userId dan mekanikId
  void _generateChatId() {
    if (_currentUser != null) {
      String userId = _currentUser!.uid;
      chatId = userId.compareTo(widget.mekanikId) < 0
          ? '${userId}_${widget.mekanikId}'
          : '${widget.mekanikId}_${userId}';
    }
  }

  // Mengirim pesan ke Firestore
  void _sendMessage() async {
  if (_messageController.text.trim().isEmpty || _currentUser == null) return;

  String messageText = _messageController.text.trim();
  _messageController.clear();

  WriteBatch batch = FirebaseFirestore.instance.batch();

  // Referensi ke chat document utama
  DocumentReference chatDocRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

  // Referensi ke koleksi messages
  CollectionReference messagesRef = chatDocRef.collection('messages');

  // Tambahkan pesan ke subkoleksi messages
  batch.set(messagesRef.doc(), {
    'senderId': _currentUser!.uid,
    'message': messageText,
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Perbarui lastMessage di chat utama
  batch.set(chatDocRef, {
    'userId': _currentUser!.uid,
    'mekanikId': widget.mekanikId,
    'lastMessage': messageText,
    'lastTimestamp': FieldValue.serverTimestamp(),
    'unreadCount': FieldValue.increment(1),
  }, SetOptions(merge: true));

  // Commit batch
  await batch.commit();
}

  @override
  Widget build(BuildContext context) {
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isUser = message['senderId'] == _currentUser!.uid;

                    // Konversi timestamp Firestore ke DateTime
                    DateTime? timestamp;
                    if (message['timestamp'] != null) {
                      timestamp = (message['timestamp'] as Timestamp).toDate();
                    }

                    return ChatBubble(
                      text: message['message'],
                      isSender: isUser,
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
