import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class CommentsScreen extends StatefulWidget {
  final String? productId;
  final String? jobId;
  final String? postId;
  const CommentsScreen({
    super.key,
    this.productId,
    this.jobId,
    this.postId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _collectionName {
    if (widget.productId != null) return 'product_comments';
    if (widget.jobId != null) return 'job_comments';
    return 'post_comments';
  }

  String get _parentId {
    if (widget.productId != null) return widget.productId!;
    if (widget.jobId != null) return widget.jobId!;
    return widget.postId!;
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentData = {
      'parentId': _parentId,
      'userId': _auth.currentUser?.uid,
      'userName': _auth.currentUser?.displayName ?? 'مستخدم',
      'comment': _commentController.text.trim(),
      'timestamp': Timestamp.now(),
    };

    await _firestore.collection(_collectionName).add(commentData);

    // ✅ تحديث عدد التعليقات في الوظيفة أو المنتج
    if (widget.jobId != null) {
      final jobRef = _firestore.collection('jobs').doc(widget.jobId);
      await jobRef.update({
        'commentCount': FieldValue.increment(1),
      });
    }

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      appBar: AppBar(
        title: const Text('التعليقات'),
        backgroundColor: const Color(0xFF5DB1DF),
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(_collectionName)
                  .where('parentId', isEqualTo: _parentId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('حدث خطأ'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('لا توجد تعليقات بعد، كن أول من يعلق!'),
                  );
                }
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(TSizes.sm),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final data = comments[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(TSizes.xs),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (data['userName'] ?? 'م')[0],
                            style: const TextStyle(color: TColors.white),
                          ),
                        ),
                        title: Text(
                          data['userName'] ?? 'مستخدم',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(data['comment'] ?? ''),
                        trailing: Text(
                          (data['timestamp'] as Timestamp)
                              .toDate()
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                          style: const TextStyle(fontSize: TSizes.fontSizeSm),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: TColors.white,
              boxShadow: [
                BoxShadow(
                  color: TColors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقك...',
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send, color: Color(0xFF429EBD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}