import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String userId;
  final String? reportedUserId;
  final String? postId;
  final String? commentId;
  final String reason;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.userId,
    this.reportedUserId,
    this.postId,
    this.commentId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      userId: data['userId'] ?? '',
      reportedUserId: data['reportedUserId'],
      postId: data['postId'],
      commentId: data['commentId'],
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'reportedUserId': reportedUserId,
      'postId': postId,
      'commentId': commentId,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}