import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class ConsultationsScreen extends StatefulWidget {
  final String? consultantId;
  final String? consultantName;
  final String? targetUserId;
  final String? targetUserName;

  /// ✅ إذا كان true → يعرض قائمة المستخدمين (وضع المستشار)
  /// إذا كان false → يعرض شاشة المحادثة مباشرة (وضع المستخدم)
  final bool isConsultantMode;

  const ConsultationsScreen({
    super.key,
    this.consultantId,
    this.consultantName,
    this.targetUserId,
    this.targetUserName,
    this.isConsultantMode = false,
  });

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  static const Color _primaryBlue = Color(0xFF5DB1DF);

  String get _consultantId =>
      widget.consultantId ?? _auth.currentUser?.uid ?? 'consultant_1';
  String get _consultantName => widget.consultantName ?? 'المستشار';
  String get _queryUserId =>
      widget.targetUserId ?? _auth.currentUser?.uid ?? '';
  String get _chatTitle =>
      widget.targetUserName ?? widget.consultantName ?? 'المستشار';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final loc = Provider.of<Language_Vm>(context, listen: false).localization;
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;
    if (_auth.currentUser == null) {
      _showSnackBar(loc.pleaseLogin, TColors.error);
      return;
    }

    _messageController.clear();
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('consultations').add({
        'userId': _queryUserId,
        'consultantId': _consultantId,
        'message': text,
        'isUser': !widget.isConsultantMode, // ✅ المستشار يرسل isUser=false
        'isRead': false,
        'timestamp': Timestamp.now(),
      });

      _scrollToBottom();

      // ✅ رد تلقائي فقط في وضع المستخدم
      if (!widget.isConsultantMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        await _firestore.collection('consultations').add({
          'userId': _queryUserId,
          'consultantId': _consultantId,
          'message':
          'شكراً لتواصلك مع $_consultantName. سيتم الرد عليك قريباً.',
          'isUser': false,
          'isRead': false,
          'timestamp': Timestamp.now(),
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) _showSnackBar('فشل إرسال الرسالة: $e', TColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;
    final userId = _auth.currentUser?.uid ?? '';

    if (userId.isEmpty) return _buildLoginRequired(isDark, loc);

    // ✅ وضع المستشار → عرض القائمة
    if (widget.isConsultantMode && widget.targetUserId == null) {
      return _buildConsultantList(isDark, userId);
    }

    // ✅ وضع المحادثة
    return _buildChatScreen(isDark, loc);
  }

  // ══════════════════════════════════════════════
  // CONSULTANT LIST — قائمة المستخدمين
  // ══════════════════════════════════════════════

  Widget _buildConsultantList(bool isDark, String consultantId) {
    return Scaffold(
      backgroundColor: isDark ? TColors.dark : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('الاستشارات'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('consultations')
            .where('consultantId', isEqualTo: consultantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildListError(isDark, snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildListEmptyState(isDark);
          }

          // ✅ استخراج المستخدمين الفريدين مع آخر رسالة
          final Map<String, Map<String, dynamic>> usersMap = {};
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final uid = data['userId'] as String? ?? '';
            if (uid.isEmpty) continue;

            if (!usersMap.containsKey(uid)) {
              usersMap[uid] = data;
            } else {
              final newTime = data['timestamp'] as Timestamp?;
              final oldTime = usersMap[uid]!['timestamp'] as Timestamp?;
              if (newTime != null &&
                  oldTime != null &&
                  newTime.compareTo(oldTime) > 0) {
                usersMap[uid] = data;
              }
            }
          }

          final users = usersMap.entries.toList()
            ..sort((a, b) {
              final aT = a.value['timestamp'] as Timestamp?;
              final bT = b.value['timestamp'] as Timestamp?;
              if (aT == null || bT == null) return 0;
              return bT.compareTo(aT);
            });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final uid = users[index].key;
              final lastData = users[index].value;
              return _buildUserTile(
                context: context,
                isDark: isDark,
                userId: uid,
                consultantId: consultantId,
                lastMessage: lastData['message'] ?? '',
                lastTimestamp: lastData['timestamp'] as Timestamp?,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile({
    required BuildContext context,
    required bool isDark,
    required String userId,
    required String consultantId,
    required String lastMessage,
    required Timestamp? lastTimestamp,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(userId).get(),
      builder: (context, userSnap) {
        String userName = 'مستخدم';
        String userEmail = '';

        if (userSnap.hasData && userSnap.data!.exists) {
          final userData = userSnap.data!.data() as Map<String, dynamic>;
          userName = userData['name'] ??
              userData['displayName'] ??
              userData['fullName'] ??
              'مستخدم';
          userEmail = userData['email'] ?? '';
        }

        final time = _formatTime(lastTimestamp);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? TColors.darkerGrey : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: _primaryBlue.withOpacity(0.15),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'م',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ),
            title: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: TSizes.fontSizeMd,
                color: isDark ? TColors.white : TColors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm,
                    color: isDark ? TColors.grey : Colors.grey.shade600,
                  ),
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? TColors.grey.withOpacity(0.6)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? TColors.grey : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                // ✅ Badge رسائل غير مقروءة
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('consultations')
                      .where('userId', isEqualTo: userId)
                      .where('consultantId', isEqualTo: consultantId)
                      .where('isUser', isEqualTo: true)
                      .where('isRead', isEqualTo: false)
                      .snapshots(),
                  builder: (context, unreadSnap) {
                    final count = unreadSnap.data?.docs.length ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConsultationsScreen(
                    consultantId: consultantId,
                    consultantName: _consultantName,
                    targetUserId: userId,
                    targetUserName: userName,
                    isConsultantMode: true, // ✅ المستشار يرد
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  // CHAT SCREEN — شاشة المحادثة
  // ══════════════════════════════════════════════

  Widget _buildChatScreen(bool isDark, dynamic loc) {
    return Scaffold(
      backgroundColor: isDark ? TColors.dark : const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList(isDark, loc)),
          if (_isLoading) _buildTypingIndicator(isDark),
          _buildInputBar(isDark, loc),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _chatTitle.isNotEmpty ? _chatTitle[0].toUpperCase() : 'م',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _chatTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'متصل الآن',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessagesList(bool isDark, dynamic loc) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('consultations')
          .where('userId', isEqualTo: _queryUserId)
          .where('consultantId', isEqualTo: _consultantId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildChatError(isDark, loc, snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildChatEmptyState(isDark);
        }

        final messages = snapshot.data!.docs;
        messages.sort((a, b) {
          final aT = (a.data() as Map)['timestamp'] as Timestamp?;
          final bT = (b.data() as Map)['timestamp'] as Timestamp?;
          if (aT == null || bT == null) return 0;
          return aT.compareTo(bT);
        });

        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            final isUser = data['isUser'] ?? false;
            final message = data['message'] ?? '';
            final timestamp = data['timestamp'] as Timestamp?;

            final showDate = index == 0 ||
                _isDifferentDay(
                  (messages[index - 1].data() as Map)['timestamp'],
                  timestamp,
                );

            // ✅ في وضع المستشار: isUser=true يعني رسالة المستخدم (يسار)
            //    في وضع المستخدم: isUser=true يعني رسالتي (يمين)
            final isMine = widget.isConsultantMode ? !isUser : isUser;

            return Column(
              children: [
                if (showDate) _buildDateDivider(timestamp),
                _buildMessageBubble(
                  message: message,
                  isMine: isMine,
                  isDark: isDark,
                  timestamp: timestamp,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMine,
    required bool isDark,
    Timestamp? timestamp,
  }) {
    final time = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
        : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
        isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _primaryBlue.withOpacity(0.15),
              child: Text(
                _chatTitle.isNotEmpty ? _chatTitle[0].toUpperCase() : 'م',
                style: TextStyle(
                  fontSize: 12,
                  color: _primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMine
                  ? _primaryBlue
                  : (isDark ? TColors.darkerGrey : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMine
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMine
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm + 1,
                    color: isMine
                        ? Colors.white
                        : (isDark ? TColors.white : TColors.black),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white.withOpacity(0.7)
                        : (isDark ? TColors.grey : Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 4),
            Icon(Icons.done_all,
                size: 14, color: _primaryBlue.withOpacity(0.7)),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 8),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkerGrey : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06), blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark, dynamic loc) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? TColors.dark
                      : const Color(0xFFF3F6FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                      color: isDark ? TColors.white : TColors.black),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: loc.writeMessage,
                    hintStyle: TextStyle(
                      color: isDark
                          ? TColors.grey
                          : Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _isLoading
                      ? _primaryBlue.withOpacity(0.5)
                      : _primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════

  Widget _buildDateDivider(Timestamp? timestamp) {
    if (timestamp == null) return const SizedBox.shrink();
    final date = timestamp.toDate();
    final now = DateTime.now();
    String label;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'اليوم';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'أمس';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500)),
          ),
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
        ],
      ),
    );
  }

  bool _isDifferentDay(dynamic prev, Timestamp? curr) {
    if (prev == null || curr == null) return false;
    final a = (prev as Timestamp).toDate();
    final b = curr.toDate();
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'أمس';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Widget _buildChatEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 50, color: _primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            'ابدأ محادثتك مع $_chatTitle',
            style: TextStyle(
              fontSize: TSizes.fontSizeMd,
              fontWeight: FontWeight.w600,
              color: isDark ? TColors.white : TColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أرسل رسالتك وسيتم الرد عليك قريباً',
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: isDark ? TColors.grey : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined,
                size: 60, color: _primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد استشارات بعد',
            style: TextStyle(
              fontSize: TSizes.fontSizeLg,
              fontWeight: FontWeight.w600,
              color: isDark ? TColors.white : TColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا رسائل المستخدمين',
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: isDark ? TColors.grey : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatError(bool isDark, dynamic loc, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: TColors.error),
          const SizedBox(height: TSizes.md),
          Text(
            '${loc.errorOccurred}: $error',
            style: TextStyle(
                color: isDark ? TColors.white : TColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.md),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListError(bool isDark, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: TColors.error),
          const SizedBox(height: TSizes.md),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDark ? TColors.white : TColors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(bool isDark, dynamic loc) {
    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        title: Text(_chatTitle),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
              Icon(Icons.lock_outline, size: 60, color: _primaryBlue),
            ),
            const SizedBox(height: TSizes.md),
            Text(
              loc.pleaseLogin,
              style: TextStyle(
                fontSize: TSizes.fontSizeLg,
                fontWeight: FontWeight.bold,
                color: isDark ? TColors.white : TColors.black,
              ),
            ),
            const SizedBox(height: TSizes.md),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(loc.login),
            ),
          ],
        ),
      ),
    );
  }
}