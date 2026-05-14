import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/product.dart';
import 'base_vm.dart';

class Search_vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      List<Product> products = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        products.add(Product(
          id: doc.id,
          category: data['category'] ?? '',
          userId: data['userId'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          name: data['name'] ?? '',
          image: data['image'],
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
}