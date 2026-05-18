import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/views/Login_View.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() =>
      _AiChatScreenState();
}

class _AiChatScreenState
    extends State<AiChatScreen> {
  final TextEditingController
  _messageController =
  TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // ================= CHECK AUTH =================

  void _checkAuth() {
    if (_auth.currentUser == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const LoginScreen(),
          ),
        );
      });
    }
  }

  // ================= SEND MESSAGE =================

  Future<void> _sendMessage() async {
    if (_messageController.text
        .trim()
        .isEmpty) {
      return;
    }

    if (_auth.currentUser == null) {
      _showError(
          'الرجاء تسجيل الدخول أولاً');
      return;
    }

    final userMessage =
    _messageController.text.trim();

    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      await _firestore
          .collection('ai_chats')
          .add({
        'userId':
        _auth.currentUser?.uid,
        'message': userMessage,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });

      final aiResponse =
          "شكراً لسؤالك! هذا رد افتراضي من المساعد الذكي. سيتم تحسين هذه الخدمة قريباً.";

      await _firestore
          .collection('ai_chats')
          .add({
        'userId':
        _auth.currentUser?.uid,
        'message': aiResponse,
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
        setState(
                () => _isLoading = false);
      }
    }
  }

  // ================= ERROR =================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TColors.error,
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context)
            .isDarkMode;

    final userId =
        _auth.currentUser?.uid ?? '';

    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F8FB);

    // ================= NO USER =================

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor:
        backgroundColor,

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          foregroundColor:
          Colors.white,

          title: const Text(
            'المساعد الذكي',
            style: TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          flexibleSpace: Container(
            decoration:
            const BoxDecoration(
              gradient:
              LinearGradient(
                colors: [
                  Color(0xFF4FA8D8),
                  Color(0xFF72C6EF),
                ],
              ),
            ),
          ),
        ),

        body: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(
              24,
            ),

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,

              children: [

                Container(
                  padding:
                  const EdgeInsets
                      .all(24),

                  decoration:
                  BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.white,

                    shape:
                    BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.05,
                        ),
                        blurRadius: 15,
                      ),
                    ],
                  ),

                  child: Icon(
                    Icons.lock_outline,
                    size: 70,
                    color:
                    TColors.primary,
                  ),
                ),

                const SizedBox(
                    height: 25),

                Text(
                  'الرجاء تسجيل الدخول أولاً',

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
                    height: 25),

                SizedBox(
                  width: 180,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator
                          .pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                          const LoginScreen(),
                        ),
                      );
                    },

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      TColors.primary,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),

                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color:
                        Colors.white,
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
      );
    }

    // ================= MAIN SCREEN =================

    return Scaffold(
      backgroundColor:
      backgroundColor,

      // ================= APP BAR =================

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor:
        Colors.white,

        title: const Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [

            CircleAvatar(
              radius: 16,
              backgroundColor:
              Colors.white24,

              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),

            SizedBox(width: 10),

            Text(
              'المساعد الذكي',
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),

        flexibleSpace: Container(
          decoration:
          const BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                Color(0xFF4FA8D8),
                Color(0xFF72C6EF),
              ],

              begin:
              Alignment.topRight,

              end: Alignment
                  .bottomLeft,
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: Column(
        children: [

          // ================= CHAT =================

          Expanded(
            child:
            StreamBuilder<
                QuerySnapshot>(
              stream: _firestore
                  .collection(
                  'ai_chats')
                  .where(
                'userId',
                isEqualTo:
                userId,
              )
                  .orderBy(
                'timestamp',
                descending:
                false,
              )
                  .snapshots(),

              builder: (
                  context,
                  snapshot,
                  ) {

                // ================= LOADING =================

                if (snapshot
                    .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      TColors.primary,
                    ),
                  );
                }

                // ================= ERROR =================

                if (snapshot
                    .hasError) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .all(20),

                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          Icon(
                            Icons
                                .error_outline,
                            size: 70,
                            color: Colors
                                .red,
                          ),

                          const SizedBox(
                              height:
                              15),

                          Text(
                            'حدث خطأ أثناء تحميل المحادثات',

                            textAlign:
                            TextAlign
                                .center,

                            style:
                            TextStyle(
                              fontSize:
                              17,
                              fontWeight:
                              FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),

                          const SizedBox(
                              height:
                              20),

                          ElevatedButton(
                            onPressed:
                                () {
                              setState(
                                      () {});
                            },

                            child:
                            const Text(
                              'إعادة المحاولة',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ================= EMPTY =================

                if (!snapshot
                    .hasData ||
                    snapshot
                        .data!
                        .docs
                        .isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .all(24),

                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          Container(
                            padding:
                            const EdgeInsets
                                .all(
                              25,
                            ),

                            decoration:
                            BoxDecoration(
                              shape:
                              BoxShape.circle,

                              color: isDark
                                  ? Colors.white10
                                  : Colors.white,

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                    0.05,
                                  ),
                                  blurRadius:
                                  15,
                                ),
                              ],
                            ),

                            child:
                            Icon(
                              Icons
                                  .chat_bubble_outline,
                              size: 70,
                              color: TColors
                                  .primary,
                            ),
                          ),

                          const SizedBox(
                              height:
                              25),

                          Text(
                            'ابدأ محادثة مع المساعد الذكي',

                            textAlign:
                            TextAlign
                                .center,

                            style:
                            TextStyle(
                              fontSize:
                              18,
                              fontWeight:
                              FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),

                          const SizedBox(
                              height:
                              10),

                          Text(
                            'اسأل أي سؤال تريده وسيتم الرد عليك',

                            textAlign:
                            TextAlign
                                .center,

                            style:
                            TextStyle(
                              fontSize:
                              14,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ================= MESSAGES =================

                final messages =
                    snapshot.data!.docs;

                return ListView.builder(
                  padding:
                  const EdgeInsets
                      .all(16),

                  itemCount:
                  messages.length,

                  itemBuilder: (
                      context,
                      index,
                      ) {
                    final data =
                    messages[index]
                        .data()
                    as Map<
                        String,
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
                        const EdgeInsets
                            .only(
                          bottom: 14,
                        ),

                        padding:
                        const EdgeInsets
                            .all(
                          16,
                        ),

                        constraints:
                        BoxConstraints(
                          maxWidth:
                          MediaQuery.of(
                            context,
                          ).size.width *
                              0.75,
                        ),

                        decoration:
                        BoxDecoration(

                          gradient:
                          isUser
                              ? const LinearGradient(
                            colors: [
                              Color(
                                0xFF4FA8D8,
                              ),
                              Color(
                                0xFF72C6EF,
                              ),
                            ],
                          )
                              : null,

                          color: isUser
                              ? null
                              : (isDark
                              ? const Color(
                            0xFF1F1F1F,
                          )
                              : Colors
                              .white),

                          borderRadius:
                          BorderRadius.only(
                            topLeft:
                            const Radius
                                .circular(
                              22,
                            ),
                            topRight:
                            const Radius
                                .circular(
                              22,
                            ),
                            bottomLeft:
                            Radius
                                .circular(
                              isUser
                                  ? 22
                                  : 0,
                            ),
                            bottomRight:
                            Radius
                                .circular(
                              isUser
                                  ? 0
                                  : 22,
                            ),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.05,
                              ),
                              blurRadius:
                              10,
                              offset:
                              const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Row(
                              mainAxisSize:
                              MainAxisSize
                                  .min,

                              children: [

                                Icon(
                                  isUser
                                      ? Icons
                                      .person
                                      : Icons
                                      .smart_toy,

                                  size: 16,

                                  color: isUser
                                      ? Colors
                                      .white
                                      : TColors
                                      .primary,
                                ),

                                const SizedBox(
                                    width:
                                    6),

                                Text(
                                  isUser
                                      ? 'أنت'
                                      : 'AI',

                                  style:
                                  TextStyle(
                                    fontWeight:
                                    FontWeight.bold,

                                    fontSize:
                                    12,

                                    color:
                                    isUser
                                        ? Colors.white
                                        : TColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height:
                                10),

                            Text(
                              data['message'] ??
                                  '',

                              style:
                              TextStyle(
                                fontSize:
                                15,
                                height:
                                1.6,

                                color:
                                isUser
                                    ? Colors
                                    .white
                                    : (isDark
                                    ? Colors.white
                                    : Colors.black87),
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

          // ================= LOADING =================

          if (_isLoading)
            const Padding(
              padding:
              EdgeInsets.only(
                bottom: 8,
              ),

              child:
              CircularProgressIndicator(
                color:
                TColors.primary,
              ),
            ),

          // ================= INPUT =================

          Container(
            padding:
            const EdgeInsets.all(
              14,
            ),

            decoration: BoxDecoration(
              color: isDark
                  ? const Color(
                  0xFF1A1A1A)
                  : Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.05,
                  ),
                  blurRadius: 10,
                  offset:
                  const Offset(
                    0,
                    -2,
                  ),
                ),
              ],
            ),

            child: SafeArea(
              child: Row(
                children: [

                  // ================= INPUT FIELD =================

                  Expanded(
                    child: Container(
                      decoration:
                      BoxDecoration(
                        color: isDark
                            ? const Color(
                            0xFF2A2A2A)
                            : const Color(
                            0xFFF1F5F9),

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: TextField(
                        controller:
                        _messageController,

                        textAlign:
                        TextAlign.right,

                        style: TextStyle(
                          color: isDark
                              ? Colors
                              .white
                              : Colors
                              .black87,
                        ),

                        decoration:
                        InputDecoration(
                          hintText:
                          'اسأل المساعد الذكي...',

                          hintStyle:
                          TextStyle(
                            color: isDark
                                ? Colors
                                .white38
                                : Colors
                                .grey,
                          ),

                          border:
                          InputBorder
                              .none,

                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            20,
                            vertical:
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  // ================= SEND BUTTON =================

                  Container(
                    height: 56,
                    width: 56,

                    decoration:
                    const BoxDecoration(
                      shape:
                      BoxShape.circle,

                      gradient:
                      LinearGradient(
                        colors: [
                          Color(
                            0xFF4FA8D8,
                          ),
                          Color(
                            0xFF72C6EF,
                          ),
                        ],
                      ),
                    ),

                    child: IconButton(
                      onPressed:
                      _isLoading
                          ? null
                          : _sendMessage,

                      icon: const Icon(
                        Icons.send_rounded,
                        color:
                        Colors.white,
                        size: 24,
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