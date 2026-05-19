import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSending = false;

  // ✅ نفس ألوان شاشة Login
  static const Color _primaryBlue = Color(0xFF429EBD);
  static const Color _lightBlue = Color(0xFF5DB1DF);

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
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;
    if (_auth.currentUser == null) return;

    setState(() => _isSending = true);
    _commentController.clear();

    try {
      await _firestore.collection(_collectionName).add({
        'parentId': _parentId,
        'userId': _auth.currentUser!.uid,
        'userName': _auth.currentUser!.displayName ?? 'مستخدم',
        'comment': text,
        'timestamp': Timestamp.now(),
      });

      if (widget.jobId != null) {
        await _firestore.collection('jobs').doc(widget.jobId).update({
          'commentCount': FieldValue.increment(1),
        });
      }

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإرسال: $e'),
            backgroundColor: TColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(14),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(String docId) async {
    await _firestore.collection(_collectionName).doc(docId).delete();
    if (widget.jobId != null) {
      await _firestore.collection('jobs').doc(widget.jobId).update({
        'commentCount': FieldValue.increment(-1),
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // ✅ نفس لون خلفية Login
      backgroundColor: _primaryBlue,
      body: Column(
        children: [
          // ══════════════════════════════════════
          // HEADER — نفس أسلوب Login
          // ══════════════════════════════════════

          SizedBox(
            height: 110,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // زر الرجوع
                  Positioned(
                    top: 4,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  // المحتوى
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.comments,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            // ✅ عداد التعليقات
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection(_collectionName)
                                  .where('parentId', isEqualTo: _parentId)
                                  .snapshots(),
                              builder: (context, snap) {
                                final count = snap.data?.docs.length ?? 0;
                                return Text(
                                  '$count ${loc.comments}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ══════════════════════════════════════
          // BODY — نفس أسلوب Login (بطاقة بيضاء)
          // ══════════════════════════════════════
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? TColors.dark : const Color(0xFFF5FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // ✅ شريط سفلي صغير للـ handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? TColors.grey.withOpacity(0.3)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // قائمة التعليقات
                  Expanded(
                    child: _buildCommentsList(isDark, loc),
                  ),

                  // حقل الإدخال
                  _buildInputBar(isDark, loc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // COMMENTS LIST
  // ──────────────────────────────────────────

  Widget _buildCommentsList(bool isDark, dynamic loc) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(_collectionName)
          .where('parentId', isEqualTo: _parentId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryBlue),
          );
        }
        if (snapshot.hasError) return _buildError(isDark, loc);
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isDark, loc);
        }

        final comments = snapshot.data!.docs;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final doc = comments[index];
            final data = doc.data() as Map<String, dynamic>;
            final isOwner = data['userId'] == _auth.currentUser?.uid;
            return _buildCommentCard(
              isDark: isDark,
              docId: doc.id,
              data: data,
              isOwner: isOwner,
              loc: loc,
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────
  // COMMENT CARD
  // ──────────────────────────────────────────

  Widget _buildCommentCard({
    required bool isDark,
    required String docId,
    required Map<String, dynamic> data,
    required bool isOwner,
    required dynamic loc,
  }) {
    final userName = data['userName'] ?? 'مستخدم';
    final comment = data['comment'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr =
    timestamp != null ? _formatTime(timestamp.toDate()) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        borderRadius: BorderRadius.circular(18),
        // ✅ حدود خفيفة بلون primaryBlue — نفس أسلوب حقول Login
        border: Border.all(
          color: _primaryBlue.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Avatar — نفس شكل اللوجو في Login
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم + وقت + حذف
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? TColors.white : Colors.black87,
                          ),
                        ),
                      ),

                      // الوقت — نفس أسلوب badge في الشاشات السابقة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // زر حذف للمالك
                      if (isOwner) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(docId, loc),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 15,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // نص التعليق
                  Text(
                    comment,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? TColors.grey
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // INPUT BAR — نفس أسلوب حقول Login
  // ──────────────────────────────────────────

  Widget _buildInputBar(bool isDark, dynamic loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ✅ حقل النص — نفس تصميم _buildTextField في Login
            Expanded(
              child: TextField(
                controller: _commentController,
                textAlign: TextAlign.right,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? TColors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: loc.writeComment,
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: isDark ? TColors.grey : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? TColors.dark
                      : const Color(0xFFF5FAFD),
                  prefixIcon: Icon(
                    Icons.mode_comment_outlined,
                    color: _primaryBlue.withOpacity(0.7),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ✅ زر الإرسال — نفس شكل زر Login
            SizedBox(
              width: 54,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSending ? null : _addComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  disabledBackgroundColor: _primaryBlue.withOpacity(0.5),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────

  void _showDeleteDialog(String docId, dynamic loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'حذف التعليق',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('هل تريد حذف هذا التعليق نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.cancel,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteComment(docId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes}د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours}س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays}ي';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState(bool isDark, dynamic loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 56,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.noComments,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${loc.beFirstComment} ✨',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? TColors.grey : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark, dynamic loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            loc.errorOccurred,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: TSizes.md),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}