import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isLoading = true);

    await _firestore.collection('ai_chats').add({
      'userId': _auth.currentUser?.uid,
      'message': userMessage,
      'isUser': true,
      'timestamp': Timestamp.now(),
    });

    final aiResponse = "شكراً لسؤالك! هذا رد افتراضي من المساعد الذكي. سيتم تحسين هذه الخدمة قريباً.";

    await _firestore.collection('ai_chats').add({
      'userId': _auth.currentUser?.uid,
      'message': aiResponse,
      'isUser': false,
      'timestamp': Timestamp.now(),
    });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة حالة الثيم
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final userId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        title: const Text('المساعد الذكي'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ai_chats')
                  .where('userId', isEqualTo: userId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ', style: TextStyle(color: isDark ? TColors.white : TColors.black)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('ابدأ محادثة مع المساعد الذكي',
                        style: TextStyle(color: isDark ? TColors.grey : TColors.darkGrey)),
                  );
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(TSizes.sm),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isUser = data['isUser'] ?? false;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(TSizes.xs),
                        padding: const EdgeInsets.all(TSizes.md),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          // ✅ ألوان الفقاعات بناءً على الوضع
                          color: isUser
                              ? TColors.primary.withOpacity(isDark ? 0.3 : 0.15)
                              : (isDark ? TColors.darkerGrey : TColors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(TSizes.cardRaduisSm),
                            topRight: const Radius.circular(TSizes.cardRaduisSm),
                            bottomLeft: isUser ? const Radius.circular(TSizes.cardRaduisSm) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(TSizes.cardRaduisSm),
                          ),
                        ),
                        child: Text(
                          data['message'] ?? '',
                          style: TextStyle(
                            fontSize: TSizes.fontSizeSm,
                            color: isDark ? TColors.white : TColors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(TSizes.sm),
              child: Center(child: CircularProgressIndicator()),
            ),

          // ✅ منطقة إرسال الرسالة
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkerGrey : TColors.white,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : TColors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: isDark ? TColors.white : TColors.black),
                    decoration: InputDecoration(
                      hintText: 'اسأل المساعد الذكي...',
                      hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                      hintTextDirection: TextDirection.rtl,
                      filled: true,
                      fillColor: isDark ? TColors.dark : TColors.softGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                CircleAvatar(
                  backgroundColor: TColors.primary,
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: TColors.white, size: 20),
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