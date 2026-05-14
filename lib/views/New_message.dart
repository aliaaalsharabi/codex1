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

  // التحكم في الحالة: هل نعرض نموذج الإنشاء أم قائمة جهات الاتصال؟
  bool _showContacts = false;

  // وحدات التحكم للنموذج
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final primaryBlue = const Color(0xFF5DB1DF);
    final cardColor = isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? TColors.white : TColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'رسالة جديدة',
          style: TextStyle(color: isDark ? TColors.white : TColors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // زر التبديل لجهات الاتصال كما في الصورة
          TextButton.icon(
            onPressed: () => setState(() => _showContacts = !_showContacts),
            icon: Icon(Icons.group_outlined, size: 20, color: primaryBlue),
            label: Text(
              _showContacts ? 'إنشاء استشارة' : 'جهات الاتصال',
              style: TextStyle(color: primaryBlue),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showContacts ? _buildContactsList(isDark, cardColor, primaryBlue) : _buildCreateConsultationForm(isDark, cardColor, primaryBlue),
      ),
    );
  }

  // الواجهة الأولى: إنشاء استشارة جديدة (مطابقة للصورة Screenshot_20260512-234347)
  Widget _buildCreateConsultationForm(bool isDark, Color cardColor, Color primaryBlue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Text(
              'إنشاء استشارة جديدة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
            const SizedBox(height: 30),

            // حقل عنوان الاستشارة
            _buildLabel('عنوان الاستشارة', Icons.title_rounded),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              decoration: _inputDecoration(isDark),
            ),

            const SizedBox(height: 25),

            // حقل وصف الاستشارة
            _buildLabel('وصف الاستشارة', Icons.description_outlined),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              textAlign: TextAlign.right,
              maxLines: 5,
              decoration: _inputDecoration(isDark),
            ),

            const SizedBox(height: 40),

            // زر الإنشاء
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // منطق حفظ الاستشارة في Firebase
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('إنشاء', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الواجهة الثانية: قائمة جهات الاتصال
  Widget _buildContactsList(bool isDark, Color cardColor, Color primaryBlue) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'بحث في جهات الاتصال',
              prefixIcon: Icon(Icons.search, color: primaryBlue),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final users = snapshot.data?.docs ?? [];
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(user['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                            Text(user['role'] ?? '', style: const TextStyle(color: TColors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(width: 15),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(user['name']?[0] ?? '?', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
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

  // مساعدات التصميم (UI Helpers)
  Widget _buildLabel(String label, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: TColors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: TColors.grey),
      ],
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? TColors.dark : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}