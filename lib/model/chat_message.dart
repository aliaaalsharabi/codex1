import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}