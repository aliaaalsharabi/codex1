import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController =
  TextEditingController();
  final TextEditingController _jobTypeController =
  TextEditingController();
  final TextEditingController _deadlineController =
  TextEditingController();

  String? _selectedCategory;
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= PICK IMAGE =================

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // ================= UPLOAD IMAGE =================

  Future<String?> _uploadImageToAppwrite() async {
    if (_selectedImage == null) return null;

    try {
      final storageService =
      Provider.of<AppwriteStorageService>(
        context,
        listen: false,
      );

      final result =
      await storageService.uploadImage(
        _selectedImage!,
      );

      final imageId = result.$id;

      print(
          '✅ تم رفع الصورة إلى Appwrite بنجاح، ID: $imageId');

      return imageId;
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');
      return null;
    }
  }

  // ================= SUBMIT POST =================

  Future<void> _submitPost() async {
    if (_selectedCategory == null) {
      _showError(
          'الرجاء اختيار النوع (وظيفة أو منتج)');
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

      String? imageId =
      await _uploadImageToAppwrite();

      if (_selectedImage != null &&
          imageId == null) {
        _showError(
            'فشل رفع الصورة، يرجى المحاولة');
        return;
      }

      // ================= JOB =================

      if (_selectedCategory == 'job') {
        final Map<String, dynamic> jobData = {
          'userId': userId,
          'nameJob':
          _titleController.text.trim(),
          'description':
          _descriptionController.text.trim(),
          'location': _locationController
              .text
              .trim()
              .isEmpty
              ? 'غير محدد'
              : _locationController.text.trim(),
          'jobType': _jobTypeController
              .text
              .trim()
              .isEmpty
              ? 'غير محدد'
              : _jobTypeController.text.trim(),
          'status': 'open',
          'imageId': imageId,
          'numberOfLike': 0,
          'likes': [],
          'commentCount': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        if (_deadlineController
            .text
            .trim()
            .isNotEmpty) {
          try {
            jobData['deadline'] =
                Timestamp.fromDate(
                  DateTime.parse(
                    _deadlineController.text.trim(),
                  ),
                );
          } catch (e) {
            print('خطأ في التاريخ: $e');
          }
        }

        await _firestore
            .collection('jobs')
            .add(jobData);

        print('✅ تم إضافة الوظيفة');
      }

      // ================= PRODUCT =================

      else {
        final Map<String, dynamic>
        productData = {
          'userId': userId,
          'name':
          _titleController.text.trim(),
          'description':
          _descriptionController.text.trim(),
          'price': double.tryParse(
              _priceController.text.trim()) ??
              0,
          'imageId': imageId,
          'category': 'general',
          'status': 'available',
          'stockQuantity': 1,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore
            .collection('products')
            .add(productData);

        print('✅ تم إضافة المنتج');
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            behavior:
            SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(14),
            ),
            content: Text(
              _selectedImage != null
                  ? 'تم النشر بنجاح مع الصورة'
                  : 'تم النشر بنجاح',
              textAlign: TextAlign.right,
            ),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ خطأ: $e');

      if (mounted) {
        _showError('حدث خطأ: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= ERROR =================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context).isDarkMode;

    final fieldFillColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF7FAFC);

    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F8FB);

    final cardColor =
    isDark ? const Color(0xFF1A1A1A) : Colors.white;

    final textStyle = TextStyle(
      color:
      isDark ? Colors.white : Colors.black87,
      fontSize: 15,
    );

    return Scaffold(
      backgroundColor: backgroundColor,

      // ================= APPBAR =================

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,

        title: const Text(
          'إضافة منشور',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4FA8D8),
                Color(0xFF72C6EF),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [

            // ================= MAIN CARD =================

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(
                      0.05,
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // ================= IMAGE =================

                  GestureDetector(
                    onTap: _pickImage,

                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 300,
                      ),

                      height: 220,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                          24,
                        ),

                        gradient:
                        _selectedImage == null
                            ? LinearGradient(
                          colors: isDark
                              ? [
                            const Color(
                                0xFF2A2A2A),
                            const Color(
                                0xFF1E1E1E),
                          ]
                              : [
                            const Color(
                                0xFFF8FBFF),
                            const Color(
                                0xFFEAF4FB),
                          ],
                        )
                            : null,

                        border: Border.all(
                          color: const Color(
                              0xFF4FA8D8)
                              .withOpacity(0.15),
                        ),
                      ),

                      child: _selectedImage != null
                          ? Stack(
                        children: [

                          ClipRRect(
                            borderRadius:
                            BorderRadius
                                .circular(
                              24,
                            ),

                            child: Image.file(
                              _selectedImage!,
                              width:
                              double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned(
                            top: 12,
                            left: 12,

                            child:
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage =
                                  null;
                                });
                              },

                              child: Container(
                                padding:
                                const EdgeInsets
                                    .all(8),

                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.black54,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),

                                child:
                                const Icon(
                                  Icons.close,
                                  color:
                                  Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          Container(
                            padding:
                            const EdgeInsets
                                .all(18),

                            decoration:
                            BoxDecoration(
                              color: const Color(
                                  0xFF4FA8D8)
                                  .withOpacity(
                                0.1,
                              ),
                              shape:
                              BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons
                                  .add_photo_alternate,
                              size: 45,
                              color: Color(
                                  0xFF4FA8D8),
                            ),
                          ),

                          const SizedBox(
                              height: 18),

                          Text(
                            'إضافة صورة',
                            style: TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                              fontSize: 17,
                              color: isDark
                                  ? Colors.white
                                  : Colors
                                  .black87,
                            ),
                          ),

                          const SizedBox(
                              height: 6),

                          Text(
                            'PNG, JPG (اختياري)',
                            style: TextStyle(
                              color: isDark
                                  ? Colors
                                  .white60
                                  : Colors
                                  .black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= CATEGORY =================

                  _buildSectionTitle(
                    'نوع المنشور',
                    isDark,
                  ),

                  const SizedBox(height: 10),

                  _buildDropdownModern(
                    isDark,
                    fieldFillColor,
                    textStyle,
                  ),

                  const SizedBox(height: 22),

                  // ================= TITLE =================

                  _buildSectionTitle(
                    'العنوان',
                    isDark,
                  ),

                  const SizedBox(height: 10),

                  _buildModernField(
                    controller: _titleController,
                    hint: 'أدخل العنوان',
                    icon: Icons.title,
                    isDark: isDark,
                    fieldFillColor:
                    fieldFillColor,
                    textStyle: textStyle,
                  ),

                  const SizedBox(height: 22),

                  // ================= DESCRIPTION =================

                  _buildSectionTitle(
                    'الوصف',
                    isDark,
                  ),

                  const SizedBox(height: 10),

                  _buildModernField(
                    controller:
                    _descriptionController,
                    hint: 'أدخل الوصف',
                    icon:
                    Icons.description_outlined,
                    isDark: isDark,
                    fieldFillColor:
                    fieldFillColor,
                    textStyle: textStyle,
                    maxLines: 5,
                  ),

                  // ================= JOB =================

                  if (_selectedCategory ==
                      'job') ...[

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'الموقع',
                      isDark,
                    ),

                    const SizedBox(height: 10),

                    _buildModernField(
                      controller:
                      _locationController,
                      hint: 'أدخل الموقع',
                      icon: Icons
                          .location_on_outlined,
                      isDark: isDark,
                      fieldFillColor:
                      fieldFillColor,
                      textStyle: textStyle,
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'نوع الوظيفة',
                      isDark,
                    ),

                    const SizedBox(height: 10),

                    _buildModernField(
                      controller:
                      _jobTypeController,
                      hint:
                      'دوام كامل / عن بعد',
                      icon:
                      Icons.work_outline,
                      isDark: isDark,
                      fieldFillColor:
                      fieldFillColor,
                      textStyle: textStyle,
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'تاريخ الانتهاء',
                      isDark,
                    ),

                    const SizedBox(height: 10),

                    _buildModernField(
                      controller:
                      _deadlineController,
                      hint: '2025-12-31',
                      icon: Icons
                          .calendar_month,
                      isDark: isDark,
                      fieldFillColor:
                      fieldFillColor,
                      textStyle: textStyle,
                    ),
                  ],

                  // ================= PRODUCT =================

                  if (_selectedCategory ==
                      'product') ...[

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'السعر',
                      isDark,
                    ),

                    const SizedBox(height: 10),

                    _buildModernField(
                      controller:
                      _priceController,
                      hint: 'أدخل السعر',
                      icon:
                      Icons.attach_money,
                      isDark: isDark,
                      fieldFillColor:
                      fieldFillColor,
                      textStyle: textStyle,
                      keyboardType:
                      TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 35),

                  // ================= BUTTON =================

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                        const Color(
                          0xFF4FA8D8,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(20),
                        ),
                      ),

                      onPressed: _isLoading
                          ? null
                          : _submitPost,

                      child: _isLoading
                          ? const SizedBox(
                        width: 25,
                        height: 25,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                          Colors.white,
                        ),
                      )
                          : const Text(
                        'نشر المنشور',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight
                              .bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget _buildSectionTitle(
      String title,
      bool isDark,
      ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color:
        isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  // ================= TEXT FIELD =================

  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color fieldFillColor,
    required TextStyle textStyle,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: textStyle,

      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection:
        TextDirection.rtl,

        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4FA8D8),
        ),

        filled: true,
        fillColor: fieldFillColor,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide(
            color:
            Colors.grey.withOpacity(0.08),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF4FA8D8),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget _buildDropdownModern(
      bool isDark,
      Color fieldFillColor,
      TextStyle textStyle,
      ) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,

      dropdownColor: isDark
          ? const Color(0xFF1E1E1E)
          : Colors.white,

      style: textStyle,

      decoration: InputDecoration(
        filled: true,
        fillColor: fieldFillColor,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 5,
        ),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide(
            color:
            Colors.grey.withOpacity(0.08),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF4FA8D8),
            width: 1.5,
          ),
        ),
      ),

      hint: Text(
        'اختر النوع',
        style: TextStyle(
          color: isDark
              ? Colors.white60
              : Colors.black54,
        ),
      ),

      items: const [

        DropdownMenuItem(
          value: 'job',
          child: Text('وظيفة'),
        ),

        DropdownMenuItem(
          value: 'product',
          child: Text('منتج'),
        ),
      ],

      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }
}