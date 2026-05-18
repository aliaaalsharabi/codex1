import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';

class ConsultationsScreen extends StatefulWidget {
  final String? consultantId;
  final String? consultantName;

  const ConsultationsScreen({
    super.key,
    this.consultantId,
    this.consultantName,
  });

  @override
  State<ConsultationsScreen> createState() =>
      _ConsultationsScreenState();
}

class _ConsultationsScreenState
    extends State<ConsultationsScreen> {
  final TextEditingController _messageController =
  TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  String get _consultantId =>
      widget.consultantId ?? 'consultant_1';

  String get _consultantName =>
      widget.consultantName ?? 'المستشار';

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (_auth.currentUser == null) {
      _showError('الرجاء تسجيل الدخول أولاً');
      return;
    }

    final userMessage =
    _messageController.text.trim();

    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('consultations').add({
        'userId': _auth.currentUser?.uid,
        'consultantId': _consultantId,
        'message': userMessage,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });

      final replyMessage =
          "شكراً لتواصلك مع $_consultantName. سيتم الرد عليك قريباً.";

      await _firestore.collection('consultations').add({
        'userId': _auth.currentUser?.uid,
        'consultantId': _consultantId,
        'message': replyMessage,
        'isUser': false,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ خطأ في الإرسال: $e');

      _showError(
        'فشل إرسال الرسالة: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context).isDarkMode;

    final userId =
        _auth.currentUser?.uid ?? '';

    final primaryColor =
    const Color(0xFF5DB1DF);

    final backgroundColor =
    isDark ? TColors.dark : const Color(0xFFF7FAFC);

    final cardColor =
    isDark ? TColors.darkerGrey : Colors.white;

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            'استشارة مع $_consultantName',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'الرجاء تسجيل الدخول أولاً',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'قم بتسجيل الدخول لبدء المحادثة مع المستشار',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/login',
                        );
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              18),
                        ),
                      ),
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

        title: Column(
          children: [
            Text(
              'استشارة مع $_consultantName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 2),

            const Text(
              'متصل الآن',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding:
            const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor:
              Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('consultations')
                  .where('userId',
                  isEqualTo: userId)
                  .where('consultantId',
                  isEqualTo:
                  _consultantId)
                  .orderBy(
                'timestamp',
                descending: false,
              )
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child:
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print(
                      '❌ خطأ في StreamBuilder: ${snapshot.error}');

                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.redAccent,
                          ),

                          const SizedBox(
                              height: 20),

                          Text(
                            'حدث خطأ أثناء تحميل الرسائل',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            '${snapshot.error}',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),

                          const SizedBox(
                              height: 25),

                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              primaryColor,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    15),
                              ),
                            ),
                            child: const Text(
                              'إعادة المحاولة',
                              style: TextStyle(
                                color:
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot
                        .data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Container(
                            padding:
                            const EdgeInsets
                                .all(25),
                            decoration:
                            BoxDecoration(
                              color: primaryColor
                                  .withOpacity(
                                  0.12),
                              shape:
                              BoxShape.circle,
                            ),
                            child: Icon(
                              Icons
                                  .chat_bubble_outline_rounded,
                              size: 65,
                              color:
                              primaryColor,
                            ),
                          ),

                          const SizedBox(
                              height: 25),

                          Text(
                            'ابدأ محادثة مع $_consultantName',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            'اكتب استشارتك وسيتم الرد عليك قريباً',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messages =
                    snapshot.data!.docs;

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  itemCount: messages.length,

                  itemBuilder:
                      (context, index) {
                    final data =
                    messages[index].data()
                    as Map<String,
                        dynamic>;

                    final isUser =
                        data['isUser'] ??
                            false;

                    return Align(
                      alignment: isUser
                          ? Alignment
                          .centerRight
                          : Alignment
                          .centerLeft,

                      child: Container(
                        margin:
                        const EdgeInsets.only(
                          bottom: 14,
                        ),

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),

                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(
                              context)
                              .size
                              .width *
                              0.78,
                        ),

                        decoration: BoxDecoration(
                          gradient: isUser
                              ? LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor
                                  .withOpacity(
                                  0.8),
                            ],
                          )
                              : null,

                          color: isUser
                              ? null
                              : cardColor,

                          borderRadius:
                          BorderRadius.only(
                            topLeft:
                            const Radius
                                .circular(24),
                            topRight:
                            const Radius
                                .circular(24),
                            bottomLeft: Radius
                                .circular(
                                isUser
                                    ? 24
                                    : 6),
                            bottomRight:
                            Radius.circular(
                                isUser
                                    ? 6
                                    : 24),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                  0.05),
                              blurRadius: 10,
                              offset:
                              const Offset(
                                  0, 4),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              data['message'] ??
                                  '',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: isUser
                                    ? Colors.white
                                    : (isDark
                                    ? Colors
                                    .white
                                    : Colors
                                    .black87),
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            Text(
                              (data['timestamp']
                              as Timestamp?)
                                  ?.toDate()
                                  .toLocal()
                                  .toString()
                                  .substring(
                                  11, 16) ??
                                  '',
                              style: TextStyle(
                                fontSize: 11,
                                color: isUser
                                    ? Colors
                                    .white70
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 10,
              ),
              child:
              CircularProgressIndicator(
                color: primaryColor,
              ),
            ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            decoration: BoxDecoration(
              color: cardColor,

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],

              borderRadius:
              const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),

            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration:
                      BoxDecoration(
                        color: isDark
                            ? TColors.dark
                            : const Color(
                            0xFFF3F7FA),

                        borderRadius:
                        BorderRadius
                            .circular(18),
                      ),

                      child: TextField(
                        controller:
                        _messageController,

                        textAlign:
                        TextAlign.right,

                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),

                        decoration:
                        InputDecoration(
                          hintText:
                          'اكتب رسالتك...',
                          hintStyle:
                          TextStyle(
                            color: isDark
                                ? TColors
                                .grey
                                : Colors.grey,
                          ),

                          hintTextDirection:
                          TextDirection.rtl,

                          border:
                          InputBorder.none,

                          contentPadding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor
                              .withOpacity(
                              0.8),
                        ],
                      ),

                      shape:
                      BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: primaryColor
                              .withOpacity(
                              0.4),
                          blurRadius: 12,
                          offset:
                          const Offset(
                              0, 5),
                        ),
                      ],
                    ),

                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : _sendMessage,

                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
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