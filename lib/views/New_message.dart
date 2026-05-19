import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/language_vm.dart';
import 'package:codex_firebase/l10n/app_localization.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showContacts = false;
  bool _isCreating = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createConsultation(AppLocalization loc) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.consultationTitle),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TSizes.borderRaduisMd)),
          margin: const EdgeInsets.all(TSizes.md),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      await _firestore.collection('consultations').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'userId': _auth.currentUser?.uid,
        'timestamp': Timestamp.now(),
        'status': 'open',
      });

      _titleController.clear();
      _descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إنشاء الاستشارة بنجاح'),
            backgroundColor: TColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.borderRaduisMd)),
            margin: const EdgeInsets.all(TSizes.md),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorOccurred}: $e'),
            backgroundColor: TColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.borderRaduisMd)),
            margin: const EdgeInsets.all(TSizes.md),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,

      // ✅ AppBar موحّد مع التطبيق
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
        title: Text(
          loc.newMessage,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: TSizes.fontSizeMd,
            color: TColors.white,
          ),
        ),
        actions: [
          // ✅ زر تبديل كـ chip بسيطة
          Padding(
            padding: const EdgeInsets.only(right: TSizes.sm),
            child: GestureDetector(
              onTap: () => setState(() => _showContacts = !_showContacts),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.md, vertical: TSizes.xs),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                  BorderRadius.circular(TSizes.borderRaduisMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showContacts
                          ? Icons.edit_outlined
                          : Icons.group_outlined,
                      size: 16,
                      color: TColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showContacts
                          ? loc.createConsultation
                          : loc.contacts,
                      style: const TextStyle(
                          color: TColors.white,
                          fontSize: TSizes.fontSizeSm,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _showContacts
            ? _buildContactsList(isDark, loc)
            : _buildCreateConsultationForm(isDark, loc),
      ),
    );
  }

  // ══════════════════════════════════════════
  // نموذج الاستشارة
  // ══════════════════════════════════════════

  Widget _buildCreateConsultationForm(bool isDark, AppLocalization loc) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(TSizes.md),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ بطاقة بنفس شكل بطاقات الهوم
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: isDark
                  ? TColors.darkerGrey
                  : const Color(0xFFF0F7FA),
              borderRadius:
              BorderRadius.circular(TSizes.cardRaduisMd),
              border: isDark
                  ? Border.all(color: Colors.white10)
                  : Border.all(
                  color: TColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ هيدر مع أيقونة
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                            TSizes.borderRaduisSm),
                      ),
                      child: const Icon(
                        Icons.create_outlined,
                        color: TColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: TSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.newConsultationTitle,
                            style: const TextStyle(
                              fontSize: TSizes.fontSizeMd,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                          Text(
                            'أرسل استشارتك للمختصين',
                            style: TextStyle(
                              fontSize: TSizes.fontSizeSm,
                              color: isDark
                                  ? TColors.grey
                                  : TColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.md),
                Divider(
                    color: isDark
                        ? Colors.white10
                        : TColors.primary.withOpacity(0.1)),
                const SizedBox(height: TSizes.md),

                // ── عنوان الاستشارة ──
                _buildLabel(loc.consultationTitle,
                    Icons.title_rounded, isDark),
                const SizedBox(height: TSizes.sm),
                _buildTextField(
                  controller: _titleController,
                  isDark: isDark,
                  hint: 'مثال: استشارة قانونية في عقد العمل',
                  maxLines: 1,
                ),

                const SizedBox(height: TSizes.md),

                // ── وصف الاستشارة ──
                _buildLabel(loc.consultationDesc,
                    Icons.description_outlined, isDark),
                const SizedBox(height: TSizes.sm),
                _buildTextField(
                  controller: _descriptionController,
                  isDark: isDark,
                  hint: 'اشرح تفاصيل استشارتك هنا...',
                  maxLines: 6,
                ),

                const SizedBox(height: TSizes.lg),

                // ✅ زر الإنشاء بنفس شكل أزرار التطبيق
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                    _isCreating ? null : () => _createConsultation(loc),
                    icon: _isCreating
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: TColors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.send_rounded,
                        color: TColors.white, size: 20),
                    label: Text(
                      _isCreating ? 'جاري الإرسال...' : loc.create,
                      style: const TextStyle(
                        fontSize: TSizes.fontSizeMd,
                        fontWeight: FontWeight.bold,
                        color: TColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCreating
                          ? TColors.primary.withOpacity(0.5)
                          : TColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            TSizes.borderRaduisMd),
                      ),
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

  // ══════════════════════════════════════════
  // قائمة جهات الاتصال
  // ══════════════════════════════════════════

  Widget _buildContactsList(bool isDark, AppLocalization loc) {
    return Column(
      key: const ValueKey('contacts'),
      children: [
        // ✅ شريط البحث بنفس شكل الهوم
        Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: isDark
                  ? TColors.darkerGrey
                  : const Color(0xFFF0F7FA),
              borderRadius: BorderRadius.circular(
                  TSizes.borderRaduisMd),
              border: Border.all(
                  color: TColors.primary.withOpacity(0.15)),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                  color:
                  isDark ? TColors.white : TColors.black),
              decoration: InputDecoration(
                hintText: loc.searchContacts,
                hintStyle: TextStyle(
                    color: isDark
                        ? TColors.grey
                        : Colors.grey),
                prefixIcon: Icon(Icons.search,
                    color: isDark
                        ? TColors.grey
                        : Colors.grey),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),

        // القائمة
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
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
                      Text(loc.errorOccurred,
                          style: TextStyle(
                              color: isDark
                                  ? TColors.white
                                  : TColors.black)),
                    ],
                  ),
                );
              }

              final allUsers = snapshot.data?.docs ?? [];
              final users = _searchQuery.isEmpty
                  ? allUsers
                  : allUsers.where((doc) {
                final data =
                doc.data() as Map<String, dynamic>;
                final name = (data['name'] as String? ?? '')
                    .toLowerCase();
                return name.contains(_searchQuery);
              }).toList();

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_outlined,
                          size: 80,
                          color: isDark
                              ? TColors.grey
                              : TColors.darkGrey),
                      const SizedBox(height: TSizes.md),
                      Text(
                        loc.searchContacts,
                        style: TextStyle(
                          fontSize: TSizes.fontSizeLg,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? TColors.grey
                              : TColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    TSizes.md, 0, TSizes.md, TSizes.md),
                itemCount: users.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final user = users[index].data()
                  as Map<String, dynamic>;
                  final name = user['name'] as String? ?? '';
                  final role = user['role'] as String? ?? '';
                  final initial =
                  name.isNotEmpty ? name[0].toUpperCase() : '?';

                  // ✅ بطاقة بنفس شكل بطاقات الهوم
                  return Container(
                    margin: const EdgeInsets.only(
                        bottom: TSizes.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? TColors.darkerGrey
                          : const Color(0xFFF0F7FA),
                      borderRadius: BorderRadius.circular(
                          TSizes.cardRaduisMd),
                      border: isDark
                          ? Border.all(color: Colors.white10)
                          : Border.all(
                          color: TColors.primary
                              .withOpacity(0.08)),
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: TSizes.md,
                          vertical: TSizes.xs),
                      onTap: () {
                        // الانتقال لشاشة الشات
                      },
                      leading: CircleAvatar(
                        backgroundColor:
                        TColors.primary.withOpacity(0.15),
                        radius: 22,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: TColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.fontSizeMd,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.fontSizeMd,
                          color: isDark
                              ? TColors.white
                              : TColors.black,
                        ),
                      ),
                      subtitle: role.isNotEmpty
                          ? Row(
                        children: [
                          Icon(Icons.work_outline,
                              size: 13,
                              color: isDark
                                  ? TColors.grey
                                  : TColors.darkGrey),
                          const SizedBox(width: 4),
                          Text(
                            role,
                            style: TextStyle(
                              fontSize:
                              TSizes.fontSizeSm,
                              color: isDark
                                  ? TColors.grey
                                  : TColors.darkGrey,
                            ),
                          ),
                        ],
                      )
                          : null,
                      trailing: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                          TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              TSizes.borderRaduisSm),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: TColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════

  Widget _buildLabel(
      String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? TColors.grey : TColors.darkGrey),
        const SizedBox(width: TSizes.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: TSizes.fontSizeSm,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.grey : TColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool isDark,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.dark : TColors.white,
        borderRadius:
        BorderRadius.circular(TSizes.borderRaduisMd),
        border:
        Border.all(color: TColors.primary.withOpacity(0.15)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: 1,
        style: TextStyle(
          fontSize: TSizes.fontSizeMd,
          color: isDark ? TColors.white : TColors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? TColors.grey : TColors.darkGrey,
            fontSize: TSizes.fontSizeSm,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: TSizes.sm,
            horizontal: TSizes.md,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(TSizes.borderRaduisMd),
            borderSide: const BorderSide(
                color: TColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}