import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart'; // ✅ استدعاء الثيم
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
    // ✅ مراقبة حالة الثيم لضبط الألوان
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final userId = _auth.currentUser?.uid ?? '';
    final primaryBlue = const Color(0xFF5DB1DF);

    return Scaffold(
      // ضبط لون الخلفية بناءً على الوضع
      backgroundColor: isDark ? TColors.dark : TColors.white,

      appBar: AppBar(
        title: const Text('محادثة مع المستشار', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: TColors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          // 1. منطقة عرض الرسائل
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', isEqualTo: userId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF5DB1DF)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ في تحميل الرسائل',
                      style: TextStyle(color: isDark ? TColors.white : TColors.black)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('لا توجد رسائل بعد، ابدأ المحادثة',
                        style: TextStyle(color: isDark ? TColors.grey : Colors.black54)),
                  );
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(TSizes.sm),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == userId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          // ألوان الفقاعات تتغير حسب الوضع (ليلي/عادي)
                          color: isMe
                              ? primaryBlue.withOpacity(isDark ? 0.8 : 0.2)
                              : (isDark ? TColors.darkerGrey : TColors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(isMe ? 15 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 15),
                          ),
                        ),
                        child: Text(
                          data['message'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? TColors.white : TColors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. منطقة إدخال الرسالة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkerGrey : TColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // زر الإرسال
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF5DB1DF)),
                ),

                // حقل النص
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: isDark ? TColors.white : TColors.black),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                      hintTextDirection: TextDirection.rtl,
                      filled: true,
                      fillColor: isDark ? TColors.dark : const Color(0xFFF0F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}