import 'package:cloud_firestore/cloud_firestore.dart';

class CallLog {
  final String id;
  final String callerId;
  final String receiverId;
  final DateTime callTime;
  final int duration; // بالثواني
  final String status; // 'missed', 'answered', 'rejected'

  CallLog({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callTime,
    required this.duration,
    required this.status,
  });

  factory CallLog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CallLog(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      callTime: (data['callTime'] as Timestamp).toDate(),
      duration: data['duration'] ?? 0,
      status: data['status'] ?? 'missed',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'callTime': Timestamp.fromDate(callTime),
      'duration': duration,
      'status': status,
    };
  }
}