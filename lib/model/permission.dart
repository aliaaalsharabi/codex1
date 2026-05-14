import 'package:cloud_firestore/cloud_firestore.dart';

class Permission {
  final String id;
  final String userId;
  final String permissionType; // 'admin', 'moderator', 'user', etc.
  final bool isActive;
  final DateTime grantedAt;
  final DateTime? expiresAt;

  Permission({
    required this.id,
    required this.userId,
    required this.permissionType,
    required this.isActive,
    required this.grantedAt,
    this.expiresAt,
  });

  factory Permission.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Permission(
      id: doc.id,
      userId: data['userId'] ?? '',
      permissionType: data['permissionType'] ?? 'user',
      isActive: data['isActive'] ?? true,
      grantedAt: (data['grantedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'permissionType': permissionType,
      'isActive': isActive,
      'grantedAt': Timestamp.fromDate(grantedAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}