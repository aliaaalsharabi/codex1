import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String? postId;
  final String? jobId;
  final String? productId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    this.postId,
    this.jobId,
    this.productId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      postId: data['postId'],
      jobId: data['jobId'],
      productId: data['productId'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'postId': postId,
      'jobId': jobId,
      'productId': productId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}