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
  final TextEditingController _commentController =
  TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

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
      'userName':
      _auth.currentUser?.displayName ?? 'مستخدم',
      'comment': _commentController.text.trim(),
      'timestamp': Timestamp.now(),
    };

    await _firestore
        .collection(_collectionName)
        .add(commentData);

    // تحديث عدد التعليقات
    if (widget.jobId != null) {
      final jobRef =
      _firestore.collection('jobs').doc(widget.jobId);

      await jobRef.update({
        'commentCount': FieldValue.increment(1),
      });
    }

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF5DB1DF);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 75,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mode_comment_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'التعليقات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [

          // ===== Comments =====
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(_collectionName)
                  .where(
                'parentId',
                isEqualTo: _parentId,
              )
                  .orderBy(
                'timestamp',
                descending: true,
              )
                  .snapshots(),

              builder: (context, snapshot) {

                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [

                        Container(
                          padding:
                          const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.red
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'حدث خطأ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [

                          Container(
                            padding:
                            const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: primaryBlue
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 65,
                              color: primaryBlue,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'لا توجد تعليقات بعد',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'كن أول من يشارك رأيه ✨',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),

                  itemCount: comments.length,

                  itemBuilder: (context, index) {

                    final data =
                    comments[index].data()
                    as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          // ===== Avatar =====
                          Container(
                            width: 50,
                            height: 50,

                            decoration: BoxDecoration(
                              gradient:
                              const LinearGradient(
                                colors: [
                                  primaryBlue,
                                  Color(0xFF429EBD),
                                ],
                              ),

                              shape: BoxShape.circle,
                            ),

                            child: Center(
                              child: Text(
                                (data['userName'] ??
                                    'م')[0]
                                    .toUpperCase(),

                                style:
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // ===== Content =====
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                // Name + Date
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                                  children: [

                                    Expanded(
                                      child: Text(
                                        data['userName'] ??
                                            'مستخدم',

                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize: 16,
                                          color:
                                          Colors.black87,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),

                                      decoration:
                                      BoxDecoration(
                                        color: primaryBlue
                                            .withOpacity(
                                            0.08),

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            12),
                                      ),

                                      child: Text(
                                        (data['timestamp']
                                        as Timestamp)
                                            .toDate()
                                            .toLocal()
                                            .toString()
                                            .split(
                                            ' ')[0],

                                        style:
                                        const TextStyle(
                                          fontSize: 11,
                                          color:
                                          primaryBlue,
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height: 10),

                                // Comment
                                Text(
                                  data['comment'] ?? '',

                                  textAlign:
                                  TextAlign.right,

                                  style:
                                  const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color:
                                    Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ================= INPUT AREA =================
          Container(
            padding: const EdgeInsets.fromLTRB(
                16, 12, 16, 18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(30),
              ),

              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),

            child: SafeArea(
              top: false,

              child: Row(
                children: [

                  // ===== Send Button =====
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primaryBlue,
                          Color(0xFF429EBD),
                        ],
                      ),

                      borderRadius:
                      BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue
                              .withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: IconButton(
                      onPressed: _addComment,

                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ===== Text Field =====
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFFF3F7FA),

                        borderRadius:
                        BorderRadius.circular(20),

                        border: Border.all(
                          color:
                          Colors.grey.shade200,
                        ),
                      ),

                      child: TextField(
                        controller:
                        _commentController,

                        textAlign:
                        TextAlign.right,

                        decoration:
                        InputDecoration(
                          hintText:
                          'اكتب تعليقك...',
                          hintTextDirection:
                          TextDirection.rtl,

                          hintStyle: TextStyle(
                            color:
                            Colors.grey.shade500,
                          ),

                          prefixIcon: Icon(
                            Icons.mode_comment_outlined,
                            color: primaryBlue
                                .withOpacity(0.7),
                          ),

                          border: InputBorder.none,

                          contentPadding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}