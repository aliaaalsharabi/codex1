import 'package:cloud_firestore/cloud_firestore.dart';

class DBAI {
  final String id;
  final String userId;
  final String prompt;
  final String response;
  final DateTime createdAt;

  DBAI({
    required this.id,
    required this.userId,
    required this.prompt,
    required this.response,
    required this.createdAt,
  });

  factory DBAI.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DBAI(
      id: doc.id,
      userId: data['userId'] ?? '',
      prompt: data['prompt'] ?? '',
      response: data['response'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'prompt': prompt,
      'response': response,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}