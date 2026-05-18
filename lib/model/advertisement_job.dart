import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdvertisementJob {
  final String idJob;
  final String userId;
  final int? numberOfLike;
  final List<String>? likes;  // ✅ أضيف قائمة المستخدمين الذين أعجبهم المنشور
  final String? commentId;
  final String nameJob;
  final String? description;
  final String? imageId;
  final String? location;
  final String? jobType;
  final String status;
  final DateTime? deadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? commentCount;  // ✅ عدد التعليقات

  AdvertisementJob({
    required this.idJob,
    required this.userId,
    this.numberOfLike,
    this.likes,
    this.commentId,
    required this.nameJob,
    this.description,
    this.imageId,
    this.location,
    this.jobType,
    required this.status,
    this.deadline,
    this.createdAt,
    this.updatedAt,
    this.commentCount,
  });

  factory AdvertisementJob.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdvertisementJob(
      idJob: doc.id,
      userId: data['userId'] ?? '',
      numberOfLike: data['numberOfLike'] ?? 0,
      likes: data['likes'] != null ? List<String>.from(data['likes']) : [],
      commentId: data['commentId'],
      nameJob: data['nameJob'] ?? '',
      description: data['description'],
      imageId: data['image'],
      location: data['location'],
      jobType: data['jobType'],
      status: data['status'] ?? 'open',
      deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'numberOfLike': numberOfLike ?? 0,
      'likes': likes ?? [],
      'commentId': commentId,
      'nameJob': nameJob,
      'description': description,
      'image': imageId,
      'location': location,
      'jobType': jobType,
      'status': status,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'commentCount': commentCount ?? 0,
    };
  }

  bool get isOpen {
    if (status != 'open') return false;
    if (deadline == null) return true;
    return deadline!.isAfter(DateTime.now());
  }

  bool get isLikedByCurrentUser {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    return likes?.contains(userId) ?? false;
  }
}