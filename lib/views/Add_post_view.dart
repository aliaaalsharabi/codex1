import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/modelview/language_vm.dart';
import 'package:codex_firebase/l10n/app_localization.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const Color _primaryBlue = Color(0xFF429EBD);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _jobTypeController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // IMAGE
  // ──────────────────────────────────────────

  Future<void> _pickImage() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      final storageService =
      Provider.of<AppwriteStorageService>(context, listen: false);
      final result = await storageService.uploadImage(_selectedImage!);
      return result.$id;
    } catch (e) {
      return null;
    }
  }

  // ──────────────────────────────────────────
  // SUBMIT
  // ──────────────────────────────────────────

  Future<void> _submitPost() async {
    final loc =
        Provider.of<Language_Vm>(context, listen: false).localization;

    if (_selectedCategory == null) {
      _showSnackBar(loc.selectType, color: Colors.orange);
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar(loc.enterTitle, color: Colors.orange);
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar(loc.enterDescription, color: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showSnackBar(loc.loginFirst, color: TColors.error);
        return;
      }

      final imageId = await _uploadImage();
      if (_selectedImage != null && imageId == null) {
        _showSnackBar(loc.uploadFailed, color: TColors.error);
        return;
      }

      if (_selectedCategory == 'job') {
        final jobData = <String, dynamic>{
          'userId': userId,
          'nameJob': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim().isEmpty
              ? loc.locationUnknown
              : _locationController.text.trim(),
          'jobType': _jobTypeController.text.trim().isEmpty
              ? loc.typeUnknown
              : _jobTypeController.text.trim(),
          'status': 'open',
          'imageId': imageId,
          'numberOfLike': 0,
          'likes': [],
          'commentCount': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        if (_deadlineController.text.trim().isNotEmpty) {
          try {
            jobData['deadline'] = Timestamp.fromDate(
              DateTime.parse(_deadlineController.text.trim()),
            );
          } catch (_) {}
        }

        await _firestore.collection('jobs').add(jobData);
      } else {
        await _firestore.collection('products').add({
          'userId': userId,
          'name': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.tryParse(_priceController.text.trim()) ?? 0,
          'imageId': imageId,
          'category': 'general',
          'status': 'available',
          'stockQuantity': 1,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }

      if (mounted) {
        _showSnackBar(
          _selectedImage != null
              ? loc.postSuccessWithImage
              : loc.postSuccess,
          color: Colors.green,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('${loc.errorOccurred}: $e', color: TColors.error);
      }
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  // ──────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _primaryBlue,
      body: Column(
        children: [
          // ══════════════════════════════════════
          // HEADER — نفس أسلوب Login
          // ══════════════════════════════════════
          SizedBox(
            height: size.height * 0.18,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 0.5,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loc.addPost,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'أضف وظيفة أو منتجاً جديداً',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ══════════════════════════════════════
          // BODY — البطاقة البيضاء
          // ══════════════════════════════════════
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                isDark ? TColors.dark : const Color(0xFFF5FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ صورة المنشور
                    _buildImagePicker(isDark),

                    const SizedBox(height: 24),

                    // ✅ النوع
                    _buildSectionLabel(loc.postType, isDark),
                    const SizedBox(height: 10),
                    _buildDropdown(isDark, loc),

                    const SizedBox(height: 20),

                    // ✅ العنوان
                    _buildSectionLabel(loc.title, isDark),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _titleController,
                      hint: loc.enterTitle,
                      icon: Icons.title_rounded,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // ✅ الوصف
                    _buildSectionLabel(loc.description, isDark),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: loc.enterDescription,
                      icon: Icons.description_outlined,
                      isDark: isDark,
                      maxLines: 4,
                    ),

                    // ✅ حقول الوظيفة
                    if (_selectedCategory == 'job') ...[
                      const SizedBox(height: 20),
                      _buildSectionLabel(loc.location, isDark),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _locationController,
                        hint: 'أدخل الموقع',
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel(loc.jobType, isDark),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _jobTypeController,
                        hint: 'دوام كامل / عن بعد',
                        icon: Icons.work_outline,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel(loc.deadline, isDark),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _deadlineController,
                        hint: '2025-12-31',
                        icon: Icons.calendar_month_outlined,
                        isDark: isDark,
                        onTap: () => _selectDate(),
                        readOnly: true,
                      ),
                    ],

                    // ✅ حقول المنتج
                    if (_selectedCategory == 'product') ...[
                      const SizedBox(height: 20),
                      _buildSectionLabel(loc.price, isDark),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _priceController,
                        hint: 'أدخل السعر',
                        icon: Icons.attach_money_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ✅ زر النشر — نفس أسلوب Login
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitPost,
                        icon: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Icon(Icons.send_rounded,
                            color: Colors.white),
                        label: Text(
                          _isLoading ? '...' : loc.submitPost,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          disabledBackgroundColor:
                          _primaryBlue.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // IMAGE PICKER
  // ──────────────────────────────────────────

  Widget _buildImagePicker(bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? TColors.darkerGrey : Colors.white,
          border: Border.all(
            color: _primaryBlue.withOpacity(
                _selectedImage != null ? 0.4 : 0.15),
            width: _selectedImage != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _selectedImage != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            // زر الحذف
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedImage = null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            // زر التغيير
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('تغيير',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 36,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'إضافة صورة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG — اختياري',
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
    );
  }

  // ──────────────────────────────────────────
  // WIDGETS
  // ──────────────────────────────────────────

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDark ? TColors.grey : Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? TColors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: TextStyle(
          color: isDark ? TColors.grey : Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? TColors.darkerGrey : Colors.white,
        prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: _primaryBlue.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark, dynamic loc) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor:
      isDark ? TColors.darkerGrey : Colors.white,
      style: TextStyle(
        color: isDark ? TColors.white : Colors.black87,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? TColors.darkerGrey : Colors.white,
        prefixIcon:
        const Icon(Icons.category_outlined, color: _primaryBlue, size: 20),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: _primaryBlue.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
      hint: Text(
        loc.selectType,
        style: TextStyle(
          color: isDark ? TColors.grey : Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'job',
          child: Row(
            children: [
              const Icon(Icons.work_outline,
                  color: _primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(loc.job),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'product',
          child: Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  color: _primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(loc.product),
            ],
          ),
        ),
      ],
      onChanged: (value) =>
          setState(() => _selectedCategory = value),
    );
  }

  // ✅ Date Picker للـ deadline
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _deadlineController.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}