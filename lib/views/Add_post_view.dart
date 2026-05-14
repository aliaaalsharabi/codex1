import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';

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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      // إنشاء اسم فريد للصورة
      final String fileName = 'jobs/${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser?.uid}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);

      // رفع الصورة مع عرض حالة التحميل
      await storageRef.putFile(_selectedImage!);

      // الحصول على رابط التحميل
      final String downloadUrl = await storageRef.getDownloadURL();
      print('✅ تم رفع الصورة بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_selectedCategory == null) {
      _showError('الرجاء اختيار النوع (وظيفة أو منتج)');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showError('الرجاء إدخال العنوان');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showError('الرجاء إدخال الوصف');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showError('يجب تسجيل الدخول أولاً');
        return;
      }

      // ✅ رفع الصورة أولاً
      String? imageUrl = await _uploadImage();

      // ✅ التحقق من رفع الصورة
      if (_selectedImage != null && imageUrl == null) {
        _showError('فشل رفع الصورة، يرجى المحاولة مرة أخرى');
        setState(() => _isLoading = false);
        return;
      }

      if (_selectedCategory == 'job') {
        // إضافة وظيفة إلى مجموعة jobs
        final Map<String, dynamic> jobData = {
          'userId': userId,
          'nameJob': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim().isEmpty ? 'موقع غير محدد' : _locationController.text.trim(),
          'jobType': _jobTypeController.text.trim().isEmpty ? 'غير محدد' : _jobTypeController.text.trim(),
          'status': 'open',
          'image': imageUrl, // ✅ حفظ رابط الصورة
          'numberOfLike': 0,
          'likes': [],
          'commentCount': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        if (_deadlineController.text.trim().isNotEmpty) {
          try {
            jobData['deadline'] = Timestamp.fromDate(DateTime.parse(_deadlineController.text.trim()));
          } catch (e) {
            print('خطأ في تحويل التاريخ: $e');
          }
        }

        await _firestore.collection('jobs').add(jobData);
        print('✅ تم إضافة الوظيفة بنجاح مع الصورة: ${imageUrl != null ? "نعم" : "لا"}');

      } else {
        // إضافة منتج إلى مجموعة products
        final Map<String, dynamic> productData = {
          'userId': userId,
          'name': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.tryParse(_priceController.text.trim()) ?? 0,
          'image': imageUrl, // ✅ حفظ رابط الصورة
          'category': 'general',
          'status': 'available',
          'stockQuantity': 1,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('products').add(productData);
        print('✅ تم إضافة المنتج بنجاح مع الصورة: ${imageUrl != null ? "نعم" : "لا"}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedImage != null ? 'تم النشر بنجاح مع الصورة' : 'تم النشر بنجاح (بدون صورة)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // ✅ إرجاع true للإشارة إلى نجاح الإضافة
      }
    } catch (e) {
      print('❌ خطأ في إضافة المنشور: $e');
      if (mounted) {
        _showError('حدث خطأ: ${e.toString()}');
      }
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
    final fieldFillColor = isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA);
    final labelStyle = TextStyle(
      fontSize: TSizes.fontSizeMd,
      fontWeight: FontWeight.bold,
      color: isDark ? TColors.white : TColors.black,
    );
    final textStyle = TextStyle(color: isDark ? TColors.white : TColors.black);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        title: const Text('إضافة منشور'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ إضافة صورة مع معاينة أفضل
            Container(
              decoration: BoxDecoration(
                color: fieldFillColor,
                borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
                border: Border.all(color: isDark ? Colors.white24 : TColors.grey, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
                          color: isDark ? TColors.dark : Colors.grey.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: isDark ? TColors.grey : TColors.darkGrey,
                            ),
                            const SizedBox(height: TSizes.sm),
                            Text(
                              'اضغط لإضافة صورة',
                              style: TextStyle(
                                color: isDark ? TColors.grey : TColors.darkGrey,
                                fontSize: TSizes.fontSizeSm,
                              ),
                            ),
                            Text(
                              '(اختياري)',
                              style: TextStyle(
                                color: isDark ? TColors.grey : TColors.darkGrey,
                                fontSize: TSizes.fontSizeSm - 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.all(TSizes.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'تم اختيار الصورة',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: TSizes.fontSizeSm,
                            ),
                          ),
                          const SizedBox(width: TSizes.sm),
                          TextButton(
                            onPressed: () => setState(() => _selectedImage = null),
                            child: const Text('إزالة'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.md),

            // النوع
            Text('النوع', style: labelStyle),
            const SizedBox(height: TSizes.sm),
            Container(
              decoration: BoxDecoration(
                color: fieldFillColor,
                borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
              ),
              child: DropdownButtonFormField<String>(
                dropdownColor: isDark ? TColors.darkerGrey : TColors.white,
                value: _selectedCategory,
                hint: Text('اختر النوع', style: TextStyle(color: isDark ? TColors.grey : Colors.grey)),
                isExpanded: true,
                style: textStyle,
                items: const [
                  DropdownMenuItem(value: 'job', child: Text('وظيفة')),
                  DropdownMenuItem(value: 'product', child: Text('منتج')),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.md),
                ),
              ),
            ),
            const SizedBox(height: TSizes.md),

            // العنوان
            Text('العنوان', style: labelStyle),
            const SizedBox(height: TSizes.sm),
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              style: textStyle,
              decoration: InputDecoration(
                hintText: 'أدخل العنوان',
                hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: fieldFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: TSizes.md),

            // الوصف
            Text('الوصف', style: labelStyle),
            const SizedBox(height: TSizes.sm),
            TextField(
              controller: _descriptionController,
              textAlign: TextAlign.right,
              maxLines: 4,
              style: textStyle,
              decoration: InputDecoration(
                hintText: 'أدخل الوصف',
                hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: fieldFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: TSizes.md),

            // حقول إضافية للوظيفة
            if (_selectedCategory == 'job') ...[
              Text('الموقع', style: labelStyle),
              const SizedBox(height: TSizes.sm),
              TextField(
                controller: _locationController,
                textAlign: TextAlign.right,
                style: textStyle,
                decoration: InputDecoration(
                  hintText: 'أدخل الموقع',
                  hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                  filled: true,
                  fillColor: fieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.md),

              Text('نوع الوظيفة', style: labelStyle),
              const SizedBox(height: TSizes.sm),
              TextField(
                controller: _jobTypeController,
                textAlign: TextAlign.right,
                style: textStyle,
                decoration: InputDecoration(
                  hintText: 'مثال: دوام كامل، عن بعد',
                  hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                  filled: true,
                  fillColor: fieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.md),

              Text('تاريخ الانتهاء (اختياري)', style: labelStyle),
              const SizedBox(height: TSizes.sm),
              TextField(
                controller: _deadlineController,
                textAlign: TextAlign.right,
                style: textStyle,
                decoration: InputDecoration(
                  hintText: 'مثال: 2025-12-31',
                  hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                  filled: true,
                  fillColor: fieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            // السعر للمنتج
            if (_selectedCategory == 'product') ...[
              Text('السعر (ريال)', style: labelStyle),
              const SizedBox(height: TSizes.sm),
              TextField(
                controller: _priceController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                style: textStyle,
                decoration: InputDecoration(
                  hintText: 'أدخل السعر',
                  hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                  hintTextDirection: TextDirection.rtl,
                  prefixText: 'ر.س ',
                  prefixStyle: TextStyle(color: isDark ? TColors.accent : TColors.primary),
                  filled: true,
                  fillColor: fieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: TSizes.lg),

            // زر النشر
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                  ),
                ),
                onPressed: _isLoading ? null : _submitPost,
                child: _isLoading
                    ? const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(strokeWidth: 2, color: TColors.white),
                )
                    : const Text(
                  'نشر',
                  style: TextStyle(fontSize: TSizes.fontSizeMd, color: TColors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}