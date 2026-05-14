import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String userId;
  final String contactId;
  final String? name;
  final DateTime addedAt;

  Contact({
    required this.id,
    required this.userId,
    required this.contactId,
    this.name,
    required this.addedAt,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      userId: data['userId'] ?? '',
      contactId: data['contactId'] ?? '',
      name: data['name'],
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'contactId': contactId,
      'name': name,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}