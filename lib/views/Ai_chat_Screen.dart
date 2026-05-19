import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/modelview/db_ai_vm.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // ✅ ID آخر رسالة AI لعرض animation ظهور فقط
  String? _lastAiMessageId;

  static const Color _primaryBlue = Color(0xFF429EBD);

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAuth() {
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
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
    final loc =
        Provider.of<Language_Vm>(context, listen: false).localization;
    if (_messageController.text.trim().isEmpty) return;
    if (_auth.currentUser == null) {
      _showSnackBar(loc.pleaseLogin, color: TColors.error);
      return;
    }

    final userMessage = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      final aiVm = Provider.of<DB_AI_Vm>(context, listen: false);
      final success = await aiVm.sendChatToLaravelAndFirebase(
        userMessage: userMessage,
        userId: _auth.currentUser!.uid,
        sanctumToken: '',
      );

      if (success) {
        // ✅ احفظ ID آخر رسالة AI لعرض animation الظهور فقط
        final snap = await _firestore
            .collection('ai_chats')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .where('isUser', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty && mounted) {
          setState(() => _lastAiMessageId = snap.docs.first.id);
        }
      } else if (aiVm.errorMessage != null) {
        _showSnackBar(aiVm.errorMessage!, color: TColors.error);
      }

      _scrollToBottom();
    } catch (e) {
      _showSnackBar('فشل معالجة الطلب: $e', color: TColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {Color color = _primaryBlue}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  void _showClearDialog() {
    final isDark =
        Provider.of<Theme_Vm>(context, listen: false).isDarkMode;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? TColors.darkerGrey : TColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('مسح المحادثة',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل تريد حذف كل المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _lastAiMessageId = null);
              Provider.of<DB_AI_Vm>(context, listen: false)
                  .clearChat(_auth.currentUser!.uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<Theme_Vm>().isDarkMode;
    final langVm = context.watch<Language_Vm>();
    final loc = langVm.localization;
    final userId = _auth.currentUser?.uid ?? '';
    final size = MediaQuery.of(context).size;

    if (userId.isEmpty) return _buildLoginRequired(isDark, loc);

    return Scaffold(
      backgroundColor: _primaryBlue,
      body: Column(
        children: [
          // HEADER
          SizedBox(
            height: size.height * 0.17,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 8,
                    child: IconButton(
                      onPressed: _showClearDialog,
                      tooltip: 'مسح المحادثة',
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: _primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${loc.aiSmartAssistant} ✨',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'مساعد Codex الذكي',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                              ),
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

          // BODY
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? TColors.dark
                    : const Color(0xFFF5FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 10, bottom: 4),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? TColors.grey.withOpacity(0.3)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildMessagesList(
                        isDark, langVm, loc, userId),
                  ),
                  if (_isLoading) _buildTypingIndicator(isDark, loc),
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
  // MESSAGES LIST
  // ──────────────────────────────────────────

  Widget _buildMessagesList(
      bool isDark,
      Language_Vm langVm,
      dynamic loc,
      String userId,
      ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ai_chats')
          .where('userId', isEqualTo: userId)
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

        final messages = List.from(snapshot.data!.docs)
          ..sort((a, b) {
            final aT =
            (a.data() as Map<String, dynamic>)['timestamp']
            as Timestamp?;
            final bT =
            (b.data() as Map<String, dynamic>)['timestamp']
            as Timestamp?;
            if (aT == null || bT == null) return 0;
            return aT.compareTo(bT);
          });

        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          itemCount: messages.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;
            final isUser = data['isUser'] ?? false;
            final message = data['message'] as String? ?? '';
            final timestamp = data['timestamp'] as Timestamp?;
            // ✅ هل هي آخر رسالة AI جديدة؟
            final isNewAi =
                !isUser && doc.id == _lastAiMessageId;

            return _buildMessageBubble(
              isDark: isDark,
              isUser: isUser,
              message: message,
              timestamp: timestamp,
              langVm: langVm,
              loc: loc,
              isNewMessage: isNewAi,
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────
  // MESSAGE BUBBLE
  // ──────────────────────────────────────────

  Widget _buildMessageBubble({
    required bool isDark,
    required bool isUser,
    required String message,
    required Language_Vm langVm,
    required dynamic loc,
    Timestamp? timestamp,
    bool isNewMessage = false,
  }) {
    final time = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
        : '';

    // ✅ animation ظهور ناعم للرسائل الجديدة بدون ارتجاج
    final bubble = Align(
      alignment: isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // أيقونة AI
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(bottom: 4, left: 6),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: _primaryBlue,
                size: 18,
              ),
            ),

          // الفقاعة
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              constraints: BoxConstraints(
                maxWidth:
                MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? _primaryBlue
                    : (isDark
                    ? TColors.darkerGrey
                    : Colors.white),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(18),
                  topEnd: const Radius.circular(18),
                  bottomStart:
                  Radius.circular(isUser ? 18 : 4),
                  bottomEnd:
                  Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ اسم المرسل — ConstrainedBox يحل overflow نهائياً
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width *
                          0.50,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUser
                              ? Icons.person_outline
                              : Icons.smart_toy_outlined,
                          size: 13,
                          color: isUser
                              ? Colors.white70
                              : _primaryBlue.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isUser ? loc.you : 'مساعد Codex',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUser
                                  ? Colors.white70
                                  : _primaryBlue
                                  .withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ✅ Markdown للـ AI — نص عادي للمستخدم
                  isUser
                      ? Text(
                    message,
                    textDirection: langVm.textDirection,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.white,
                    ),
                  )
                      : MarkdownBody(
                    data: message,
                    shrinkWrap: true,
                    fitContent: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark
                            ? TColors.white
                            : Colors.black87,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? TColors.white
                            : Colors.black87,
                      ),
                      em: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? TColors.white
                            : Colors.black87,
                      ),
                      listBullet: const TextStyle(
                        fontSize: 14,
                        color: _primaryBlue,
                      ),
                      h1: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      h2: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      h3: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      code: TextStyle(
                        fontSize: 13,
                        backgroundColor: isDark
                            ? Colors.black26
                            : Colors.grey.shade100,
                        color: _primaryBlue,
                      ),
                      blockquote: TextStyle(
                        color: isDark
                            ? TColors.grey
                            : Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // الوقت
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser
                            ? Colors.white.withOpacity(0.6)
                            : (isDark
                            ? TColors.grey
                            : Colors.grey.shade400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // double tick
          if (isUser)
            Padding(
              padding:
              const EdgeInsets.only(bottom: 4, right: 4),
              child: Icon(
                Icons.done_all,
                size: 14,
                color: _primaryBlue.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );

    // ✅ animation ظهور ناعم للرسائل الجديدة فقط
    if (isNewMessage) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (_, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        ),
        child: bubble,
      );
    }

    return bubble;
  }

  // ──────────────────────────────────────────
  // TYPING INDICATOR
  // ──────────────────────────────────────────

  Widget _buildTypingIndicator(bool isDark, dynamic loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: _primaryBlue, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkerGrey : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: _primaryBlue,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.analyzing,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? TColors.grey
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // INPUT BAR
  // ──────────────────────────────────────────

  Widget _buildInputBar(bool isDark, dynamic loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) =>
                _isLoading ? null : _sendMessage(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? TColors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: loc.askAi,
                  hintStyle: TextStyle(
                    color: isDark
                        ? TColors.grey
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? TColors.dark
                      : const Color(0xFFF5FAFD),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 13, horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _primaryBlue.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: _primaryBlue, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _isLoading
                      ? _primaryBlue.withOpacity(0.5)
                      : _primaryBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isLoading
                      ? []
                      : [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // EMPTY STATE
  // ──────────────────────────────────────────

  Widget _buildEmptyState(bool isDark, dynamic loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                Icons.chat_bubble_outline_rounded,
                size: 52,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.startConversation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? TColors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'مساعدك الذكي لإيجاد الوظائف والمنتجات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:
                isDark ? TColors.grey : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                '💼 ابحث لي عن وظائف متاحة',
                '🛍️ ساعدني في وصف منتجي',
                '📝 كيف أنشئ إعلاناً جيداً؟',
                '🔍 ما أفضل مهارات السوق؟',
              ].map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    _messageController.text =
                        suggestion.substring(3);
                    _sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _primaryBlue.withOpacity(0.2)),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // ERROR STATE
  // ──────────────────────────────────────────

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
            child: const Icon(Icons.error_outline,
                color: Colors.red, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            loc.errorOccurred,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // LOGIN REQUIRED
  // ──────────────────────────────────────────

  Widget _buildLoginRequired(bool isDark, dynamic loc) {
    return Scaffold(
      backgroundColor: _primaryBlue,
      body: Column(
        children: [
          SizedBox(
            height: 160,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      color: _primaryBlue, size: 32),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? TColors.dark
                    : const Color(0xFFF5FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline,
                        size: 52, color: _primaryBlue),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.pleaseLogin,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? TColors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14)),
                      ),
                      child: Text(
                        loc.login,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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