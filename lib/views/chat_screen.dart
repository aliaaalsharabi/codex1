import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _consultantId = "consultant_1";

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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final userId = _auth.currentUser?.uid ?? '';

    const Color primaryBlue = Color(0xFF5DB1DF);
    final bgColor = isDark ? TColors.dark : const Color(0xFFF7FAFC);
    final cardColor = isDark ? TColors.darkerGrey : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,

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
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 10),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محادثة مع المستشار',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'متصل الآن',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [

          // ===== Messages =====
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', isEqualTo: userId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),

              builder: (context, snapshot) {

                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 45,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'حدث خطأ في تحميل الرسائل',
                          style: TextStyle(
                            color: isDark
                                ? TColors.white
                                : TColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty Chat
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 65,
                              color: primaryBlue,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Text(
                            'ابدأ المحادثة مع المستشار',
                            style: TextStyle(
                              color: isDark
                                  ? TColors.white
                                  : TColors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'يمكنك إرسال استفساراتك البرمجية\nوسيتم الرد عليك مباشرة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? TColors.grey
                                  : Colors.black54,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 20,
                  ),

                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final data =
                    messages[index].data() as Map<String, dynamic>;

                    final isMe =
                        data['senderId'] == userId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.78,
                        ),

                        decoration: BoxDecoration(
                          gradient: isMe
                              ? LinearGradient(
                            colors: [
                              primaryBlue,
                              primaryBlue.withOpacity(0.85),
                            ],
                          )
                              : null,

                          color: isMe
                              ? null
                              : cardColor,

                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(22),
                            topRight: const Radius.circular(22),

                            bottomLeft: Radius.circular(
                              isMe ? 22 : 5,
                            ),

                            bottomRight: Radius.circular(
                              isMe ? 5 : 22,
                            ),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],

                          border: !isMe
                              ? Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade200,
                          )
                              : null,
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              data['message'] ?? '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 15.5,
                                height: 1.6,
                                fontWeight: FontWeight.w500,

                                color: isMe
                                    ? Colors.white
                                    : (isDark
                                    ? Colors.white
                                    : Colors.black87),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Icon(
                                  Icons.done_all_rounded,
                                  size: 15,
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  'الآن',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey,
                                  ),
                                ),
                              ],
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

          // ================= INPUT AREA =================
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),

            decoration: BoxDecoration(
              color: cardColor,

              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),

            child: SafeArea(
              top: false,

              child: Row(
                children: [

                  // Send Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primaryBlue,
                          Color(0xFF429EBD),
                        ],
                      ),

                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: IconButton(
                      onPressed: _sendMessage,

                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? TColors.dark
                            : const Color(0xFFF3F7FA),

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.grey.shade200,
                        ),
                      ),

                      child: TextField(
                        controller: _messageController,

                        textAlign: TextAlign.right,

                        style: TextStyle(
                          color: isDark
                              ? TColors.white
                              : TColors.black,
                          fontSize: 15,
                        ),

                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          hintTextDirection: TextDirection.rtl,

                          hintStyle: TextStyle(
                            color: isDark
                                ? TColors.grey
                                : Colors.grey.shade500,
                          ),

                          prefixIcon: Icon(
                            Icons.chat_outlined,
                            color: primaryBlue.withOpacity(0.7),
                          ),

                          border: InputBorder.none,

                          contentPadding:
                          const EdgeInsets.symmetric(
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