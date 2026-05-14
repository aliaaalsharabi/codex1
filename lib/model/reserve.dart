import 'package:cloud_firestore/cloud_firestore.dart';

class Reserve {
  final String id;
  final String userId;
  final String? consultationId;
  final DateTime reserveDate;
  final String status;
  final DateTime createdAt;

  Reserve({
    required this.id,
    required this.userId,
    this.consultationId,
    required this.reserveDate,
    required this.status,
    required this.createdAt,
  });

  factory Reserve.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reserve(
      id: doc.id,
      userId: data['userId'] ?? '',
      consultationId: data['consultationId'],
      reserveDate: (data['reserveDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'consultationId': consultationId,
      'reserveDate': Timestamp.fromDate(reserveDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}