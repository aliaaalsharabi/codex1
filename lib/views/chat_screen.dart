import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _consultantId = 'consultant_1';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.positions.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final message = _messageController.text.trim();
    _messageController.clear();

    await _firestore.collection('chats').add({
      'senderId': _auth.currentUser?.uid,
      'receiverId': _consultantId,
      'message': message,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;
    final userId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,

      // ✅ AppBar بنفس شكل التطبيق
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: TColors.white, size: 20),
        ),
        title: Row(
          children: [
            // ✅ صورة المستشار
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(
                    TSizes.borderRaduisSm),
              ),
              child: const Icon(Icons.support_agent,
                  color: TColors.white, size: 20),
            ),
            const SizedBox(width: TSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.chatWithConsultant,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.fontSizeMd,
                    color: TColors.white,
                  ),
                ),
                // ✅ حالة الاتصال
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'متصل الآن',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ══════════════════════════════════════
          // قائمة الرسائل
          // ══════════════════════════════════════
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', isEqualTo: userId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: TColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60,
                            color: isDark
                                ? TColors.grey
                                : TColors.darkGrey),
                        const SizedBox(height: TSizes.md),
                        Text(
                          loc.errorOccurred,
                          style: TextStyle(
                            fontSize: TSizes.fontSizeMd,
                            color: isDark
                                ? TColors.white
                                : TColors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 80,
                          color: isDark
                              ? TColors.grey
                              : TColors.darkGrey,
                        ),
                        const SizedBox(height: TSizes.md),
                        Text(
                          loc.noMessages,
                          style: TextStyle(
                            fontSize: TSizes.fontSizeLg,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? TColors.grey
                                : TColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: TSizes.sm),
                        Text(
                          'ابدأ المحادثة مع المستشار',
                          style: TextStyle(
                            fontSize: TSizes.fontSizeSm,
                            color: isDark
                                ? TColors.grey
                                : TColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      TSizes.md, TSizes.sm, TSizes.md, TSizes.sm),
                  itemCount: messages.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = messages[index].data()
                    as Map<String, dynamic>;
                    final isMe = data['senderId'] == userId;
                    final message =
                        data['message'] as String? ?? '';
                    final timestamp =
                    data['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? TimeOfDay.fromDateTime(
                        timestamp.toDate())
                        .format(context)
                        : '';

                    return Align(
                      alignment: isMe
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          // أيقونة المستشار
                          if (!isMe)
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(
                                  bottom: 4, left: 4),
                              decoration: BoxDecoration(
                                color: TColors.primary
                                    .withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(
                                    TSizes.borderRaduisSm),
                                border: Border.all(
                                    color: TColors.primary
                                        .withOpacity(0.2)),
                              ),
                              child: const Icon(
                                Icons.support_agent,
                                color: TColors.primary,
                                size: 18,
                              ),
                            ),

                          // الفقاعة
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: TSizes.sm),
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.72,
                              ),
                              decoration: BoxDecoration(
                                // ✅ نفس ألوان بطاقات الهوم
                                color: isMe
                                    ? TColors.primary
                                    : (isDark
                                    ? TColors.darkerGrey
                                    : const Color(
                                    0xFFF0F7FA)),
                                borderRadius:
                                BorderRadiusDirectional
                                    .only(
                                  topStart:
                                  const Radius.circular(
                                      TSizes.cardRaduisMd),
                                  topEnd:
                                  const Radius.circular(
                                      TSizes.cardRaduisMd),
                                  bottomStart: Radius.circular(
                                      isMe
                                          ? TSizes.cardRaduisMd
                                          : 4),
                                  bottomEnd: Radius.circular(
                                      isMe
                                          ? 4
                                          : TSizes.cardRaduisMd),
                                ),
                                border: (!isMe && !isDark)
                                    ? Border.all(
                                    color: TColors.primary
                                        .withOpacity(0.1))
                                    : (isDark
                                    ? Border.all(
                                    color:
                                    Colors.white10)
                                    : null),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding:
                              const EdgeInsets.all(TSizes.md),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // اسم المرسل
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.50,
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isMe
                                              ? Icons
                                              .person_outline
                                              : Icons
                                              .support_agent,
                                          size: 13,
                                          color: isMe
                                              ? TColors.white
                                              .withOpacity(
                                              0.8)
                                              : TColors.primary
                                              .withOpacity(
                                              0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            isMe
                                                ? loc.you
                                                : loc.chatWithConsultant,
                                            overflow: TextOverflow
                                                .ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: TSizes
                                                  .fontSizeSm,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: isMe
                                                  ? TColors.white
                                                  .withOpacity(
                                                  0.8)
                                                  : TColors
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                      height: TSizes.xs),

                                  // نص الرسالة
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: TSizes.fontSizeMd,
                                      height: 1.6,
                                      color: isMe
                                          ? TColors.white
                                          : (isDark
                                          ? TColors.white
                                          : TColors
                                          .textprimary),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // الوقت + tick
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontSize:
                                          TSizes.fontSizeSm,
                                          color: isMe
                                              ? TColors.white
                                              .withOpacity(
                                              0.6)
                                              : (isDark
                                              ? TColors.grey
                                              : TColors
                                              .darkGrey),
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.done_all,
                                          size: 13,
                                          color: TColors.white
                                              .withOpacity(0.6),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (!isMe)
                            const SizedBox(width: TSizes.xs),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ══════════════════════════════════════
          // Input Bar
          // ══════════════════════════════════════
          Container(
            padding: const EdgeInsets.fromLTRB(
                TSizes.md, TSizes.sm, TSizes.md, TSizes.md),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkerGrey : TColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // حقل النص
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? TColors.dark
                            : const Color(0xFFF0F7FA),
                        borderRadius: BorderRadius.circular(
                            TSizes.borderRaduisMd),
                        border: Border.all(
                            color:
                            TColors.primary.withOpacity(0.15)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(
                          fontSize: TSizes.fontSizeMd,
                          color: isDark
                              ? TColors.white
                              : TColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: loc.writeMessage,
                          hintStyle: TextStyle(
                            color: isDark
                                ? TColors.grey
                                : TColors.darkGrey,
                            fontSize: TSizes.fontSizeMd,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: TSizes.sm,
                              horizontal: TSizes.md),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                TSizes.borderRaduisMd),
                            borderSide: const BorderSide(
                                color: TColors.primary,
                                width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: TSizes.sm),

                  // ✅ زر الإرسال بنفس شكل FAB الهوم
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(
                            TSizes.borderRaduisMd),
                        boxShadow: [
                          BoxShadow(
                            color:
                            TColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: TColors.white,
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