import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productName; 
  final int quantity;
  final double price;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.addedAt,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0).toDouble(),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}