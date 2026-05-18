import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String category;
  final String userId;
  final double price;
  final String name;
  final String? imageId;
  final String? description;
  final int stockQuantity;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.category,
    required this.userId,
    required this.price,
    required this.name,
    this.imageId,
    this.description,
    required this.stockQuantity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      category: data['category'] ?? '',
      userId: data['userId'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      name: data['name'] ?? '',
      imageId: data['image'],
      description: data['description'],
      stockQuantity: data['stockQuantity'] ?? 0,
      status: data['status'] ?? 'available',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'userId': userId,
      'price': price,
      'name': name,
      'image': imageId,
      'description': description,
      'stockQuantity': stockQuantity,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}