import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/model/cart_item.dart';
import 'package:codex_firebase/model/product.dart';

class Cart_Vm extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  CollectionReference get _cartRef => _firestore.collection('carts');

  // ✅ Stream مباشر من Firestore
  Stream<List<CartItem>> get cartStream => _cartRef
      .where('userId', isEqualTo: _userId)
      .snapshots()
      .map((snap) {
    final items = snap.docs
        .map((doc) => CartItem.fromFirestore(doc))
        .toList();
    // ✅ ترتيب محلي بدل orderBy (يتجنب مشكلة الـ index)
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return items;
  });

  // ✅ إضافة منتج للسلة
  Future<void> addToCart(Product product) async {
    if (_userId.isEmpty) return;

    final existing = await _cartRef
        .where('userId', isEqualTo: _userId)
        .where('productId', isEqualTo: product.id)
        .get();

    if (existing.docs.isNotEmpty) {
      // ✅ زيد الكمية إذا المنتج موجود
      await _cartRef.doc(existing.docs.first.id).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // ✅ أضف عنصر جديد
      await _cartRef.add({
        'userId': _userId,
        'productId': product.id,
        'productName': product.name,
        'quantity': 1,
        'price': product.price,
        'imageId': product.imageId ?? '',
        'addedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
    notifyListeners();
  }

  // ✅ حذف عنصر
  Future<void> removeFromCart(String cartItemId) async {
    await _cartRef.doc(cartItemId).delete();
    notifyListeners();
  }

  // ✅ تغيير الكمية
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _cartRef.doc(cartItemId).update({'quantity': quantity});
      notifyListeners();
    }
  }

  // ✅ تفريغ السلة بالكامل
  Future<void> clearCart() async {
    final items = await _cartRef
        .where('userId', isEqualTo: _userId)
        .get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
    notifyListeners();
  }

  // ✅ عدد العناصر في السلة (للـ badge)
  Stream<int> get cartCountStream => _cartRef
      .where('userId', isEqualTo: _userId)
      .snapshots()
      .map((snap) => snap.docs.length);

  // ✅ المجموع الكلي
  Stream<double> get totalPriceStream => _cartRef
      .where('userId', isEqualTo: _userId)
      .snapshots()
      .map((snap) => snap.docs.fold(0.0, (sum, doc) {
    final data = doc.data() as Map<String, dynamic>;
    final price = (data['price'] ?? 0).toDouble();
    final qty = (data['quantity'] ?? 1) as int;
    return sum + (price * qty);
  }));
}