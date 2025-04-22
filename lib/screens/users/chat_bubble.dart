import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final DateTime? timestamp;

  const ChatBubble({super.key, required this.text, required this.isSender, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSender ? Colors.blue.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isSender ? 12 : 0),
              bottomRight: Radius.circular(isSender ? 0 : 12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        if (timestamp != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 6, left: 6),
            child: Text(
              DateFormat('HH:mm').format(timestamp!),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
