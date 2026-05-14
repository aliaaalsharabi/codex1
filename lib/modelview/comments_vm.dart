import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/comment.dart';
import 'base_vm.dart';

class Comments_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Comment>> getCommentsByProduct(String productId) async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('productId', isEqualTo: productId)
          .get();
      List<Comment> comments = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        comments.add(Comment(
          id: doc.id,
          userId: data['userId'] ?? '',
          productId: data['productId'],
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        ));
      }
      return comments;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      setLoading(true);
      await _firestore.collection('comments').doc(comment.id).set({
        'userId': comment.userId,
        'productId': comment.productId,
        'content': comment.content,
        'createdAt': Timestamp.fromDate(comment.createdAt),
      });
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}