import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';

class ConsultationsScreen extends StatefulWidget {
  final String? consultantId; // معرف المستشار (اختياري)
  final String? consultantName; // اسم المستشار
  const ConsultationsScreen({super.key, this.consultantId, this.consultantName});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // معرف المستشار الافتراضي إذا لم يتم تمريره
  String get _consultantId => widget.consultantId ?? 'consultant_1';
  String get _consultantName => widget.consultantName ?? 'المستشار';

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_auth.currentUser == null) {
      _showError('الرجاء تسجيل الدخول أولاً');
      return;
    }

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      // حفظ رسالة المستخدم
      await _firestore.collection('consultations').add({
        'userId': _auth.currentUser?.uid,
        'consultantId': _consultantId,
        'message': userMessage,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });

      // ✅ رد تلقائي من المستشار (يمكن استبداله بـ API حقيقي لاحقًا)
      final replyMessage = "شكراً لتواصلك مع $_consultantName. سيتم الرد عليك قريباً.";

      await _firestore.collection('consultations').add({
        'userId': _auth.currentUser?.uid,
        'consultantId': _consultantId,
        'message': replyMessage,
        'isUser': false,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ خطأ في الإرسال: $e');
      _showError('فشل إرسال الرسالة: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: TColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final userId = _auth.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? TColors.dark : TColors.white,
        appBar: AppBar(
          title: Text('استشارة مع $_consultantName'),
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: TColors.grey),
              const SizedBox(height: TSizes.md),
              Text(
                'الرجاء تسجيل الدخول أولاً',
                style: TextStyle(color: isDark ? TColors.white : TColors.black),
              ),
              const SizedBox(height: TSizes.md),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        title: Text('استشارة مع $_consultantName'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('consultations')
                  .where('userId', isEqualTo: userId)
                  .where('consultantId', isEqualTo: _consultantId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('❌ خطأ في StreamBuilder: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: TColors.error),
                        const SizedBox(height: TSizes.md),
                        Text(
                          'حدث خطأ: ${snapshot.error}',
                          style: TextStyle(color: isDark ? TColors.white : TColors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TSizes.md),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: TColors.grey),
                        const SizedBox(height: TSizes.md),
                        Text(
                          'ابدأ محادثة مع $_consultantName',
                          style: TextStyle(color: isDark ? TColors.grey : TColors.darkGrey),
                        ),
                      ],
                    ),
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
                      hintText: 'اكتب رسالتك...',
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