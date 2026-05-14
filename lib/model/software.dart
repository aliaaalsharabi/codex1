import 'package:cloud_firestore/cloud_firestore.dart';

class Software {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? version;
  final String? downloadUrl;
  final String? image;
  final DateTime? createdAt;

  Software({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.version,
    this.downloadUrl,
    this.image,
    this.createdAt,
  });

  factory Software.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Software(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      version: data['version'],
      downloadUrl: data['downloadUrl'],
      image: data['image'],
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'version': version,
      'downloadUrl': downloadUrl,
      'image': image,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}