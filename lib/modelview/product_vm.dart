import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/product.dart';
import 'base_vm.dart';

class Prodect_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> fetchAllProducts() async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      List<Product> products = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        products.add(Product(
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
        ));
      }
      return products;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      setLoading(true);
      await _firestore.collection('products').doc(product.id).set({
        'category': product.category,
        'userId': product.userId,
        'price': product.price,
        'name': product.name,
        'image': product.imageId,
        'description': product.description,
        'stockQuantity': product.stockQuantity,
        'status': product.status,
        'createdAt': product.createdAt != null ? Timestamp.fromDate(product.createdAt!) : null,
      });
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
  // دالة جلب منتج بواسطة ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      setLoading(true);
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        return null;
      }
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'price': data['price'] ?? 0,
        'image': data['image'],
        'description': data['description'],
        'category': data['category'] ?? '',
        'stockQuantity': data['stockQuantity'] ?? 0,
        'userId': data['userId'] ?? '',
      };
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }
}