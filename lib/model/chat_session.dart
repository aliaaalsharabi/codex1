import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatSession(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}