import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showContacts = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;

    const Color primaryBlue = Color(0xFF5DB1DF);

    final Color backgroundColor =
    isDark ? const Color(0xFF0F172A) : const Color(0xFFF6FBFF);

    final Color cardColor =
    isDark ? const Color(0xFF1E293B) : Colors.white;

    final Color fieldColor =
    isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F8FC);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        title: Text(
          'رسالة جديدة',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _showContacts = !_showContacts),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showContacts
                          ? Icons.edit_note_rounded
                          : Icons.group_rounded,
                      size: 18,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showContacts
                          ? 'إنشاء استشارة'
                          : 'جهات الاتصال',
                      style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showContacts
            ? _buildContactsList(
          isDark,
          cardColor,
          fieldColor,
          primaryBlue,
        )
            : _buildCreateConsultationForm(
          isDark,
          cardColor,
          fieldColor,
          primaryBlue,
        ),
      ),
    );
  }

  // ================= CREATE CONSULTATION =================

  Widget _buildCreateConsultationForm(
      bool isDark,
      Color cardColor,
      Color fieldColor,
      Color primaryBlue,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.md),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // HEADER CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryBlue,
                  primaryBlue.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'إنشاء استشارة جديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اكتب تفاصيل استشارتك ليتمكن المستشار من مساعدتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // FORM CARD
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildLabel(
                  'عنوان الاستشارة',
                  Icons.title_rounded,
                  isDark,
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _titleController,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _inputDecoration(
                    isDark,
                    fieldColor,
                    'اكتب عنوان الاستشارة',
                  ),
                ),

                const SizedBox(height: 28),

                _buildLabel(
                  'وصف الاستشارة',
                  Icons.description_rounded,
                  isDark,
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _descriptionController,
                  textAlign: TextAlign.right,
                  maxLines: 6,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _inputDecoration(
                    isDark,
                    fieldColor,
                    'اشرح مشكلتك أو استفسارك بالتفصيل',
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      // منطق الحفظ
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'إنشاء',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  // ================= CONTACTS =================

  Widget _buildContactsList(
      bool isDark,
      Color cardColor,
      Color fieldColor,
      Color primaryBlue,
      ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'بحث في جهات الاتصال',
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: primaryBlue,
              ),
              filled: true,
              fillColor: fieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final users = snapshot.data?.docs ?? [];

              if (users.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد جهات اتصال',
                    style: TextStyle(
                      color:
                      isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.md,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user =
                  users[index].data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                          primaryBlue.withOpacity(0.15),
                          child: Text(
                            user['name']?[0] ?? '?',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                user['role'] ?? '',
                                style: const TextStyle(
                                  color: TColors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.chat_rounded,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ],
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

  // ================= HELPERS =================

  Widget _buildLabel(
      String label,
      IconData icon,
      bool isDark,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF5DB1DF),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      bool isDark,
      Color fieldColor,
      String hint,
      ) {
    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      hintStyle: TextStyle(
        color: isDark ? Colors.white54 : Colors.grey,
      ),
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF5DB1DF),
          width: 1.5,
        ),
      ),
    );
  }
}