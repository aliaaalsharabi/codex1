import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final userVm =
    Provider.of<User_Vm>(context, listen: false);

    final user = userVm.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final Map<String, dynamic> updates = {};

    final currentUser =
        Provider.of<User_Vm>(
          context,
          listen: false,
        ).currentUser;

    final newName =
    _nameController.text.trim();

    if (newName.isNotEmpty &&
        newName != currentUser?.name) {
      updates['name'] = newName;
    }

    final newPhone =
    _phoneController.text.trim();

    if (newPhone.isNotEmpty &&
        newPhone != (currentUser?.phone ?? '')) {
      updates['phone'] = newPhone;
    }

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا توجد تغييرات لحفظها',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userVm =
      Provider.of<User_Vm>(
        context,
        listen: false,
      );

      final result =
      await userVm.updateUser(updates);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'تم تحديث الملف الشخصي بنجاح',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                userVm.errorMessage ??
                    'حدث خطأ أثناء التحديث',
              ),
              backgroundColor: TColors.error,
              behavior:
              SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: ${e.toString()}',
            ),
            backgroundColor: TColors.error,
            behavior:
            SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    final fieldFillColor =
    isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF5F9FC);

    final iconColor =
    isDark
        ? TColors.accent
        : const Color(0xFF429EBD);

    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.12 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,

        style: TextStyle(
          color:
          isDark
              ? TColors.white
              : TColors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(
            color:
            isDark
                ? TColors.grey
                : Colors.grey,
          ),

          hintTextDirection:
          TextDirection.rtl,

          filled: true,
          fillColor: fieldFillColor,

          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(22),
            borderSide: BorderSide(
              color:
              isDark
                  ? Colors.white10
                  : Colors.transparent,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: TColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context).isDarkMode;

    final backgroundColor =
    isDark
        ? TColors.dark
        : const Color(0xFFF7FAFC);

    final cardColor =
    isDark
        ? const Color(0xFF111827)
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,

        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // صورة الملف الشخصي
            Container(
              padding: const EdgeInsets.all(5),

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    TColors.primary,
                    TColors.primary.withOpacity(0.7),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color: TColors.primary
                        .withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: CircleAvatar(
                radius: 52,
                backgroundColor: cardColor,

                child: Icon(
                  Icons.person_rounded,
                  size: 55,
                  color:
                  isDark
                      ? TColors.white
                      : TColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'تعديل معلومات الحساب',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:
                isDark
                    ? TColors.white
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'قم بتحديث بياناتك الشخصية بسهولة',
              style: TextStyle(
                fontSize: 14,
                color:
                isDark
                    ? Colors.white60
                    : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 35),

            // البطاقة الرئيسية
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius:
                BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? 0.15 : 0.06,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'البيانات الشخصية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                      isDark
                          ? TColors.white
                          : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // الاسم
                  _buildTextField(
                    controller: _nameController,
                    hint: 'الاسم',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 22),

                  // رقم الهاتف
                  _buildTextField(
                    controller:
                    _phoneController,
                    hint: 'رقم الهاتف',
                    icon: Icons.phone_outlined,
                    isDark: isDark,
                    keyboardType:
                    TextInputType.phone,
                  ),

                  const SizedBox(height: 35),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed:
                      _isLoading
                          ? null
                          : _saveChanges,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        TColors.primary,
                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),

                      child:
                      _isLoading
                          ? const SizedBox(
                        width: 26,
                        height: 26,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                          Colors
                              .white,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons
                                .save_rounded,
                            color:
                            Colors
                                .white,
                          ),

                          SizedBox(
                            width: 10,
                          ),

                          Text(
                            'حفظ التغييرات',
                            style: TextStyle(
                              fontSize: 17,
                              color:
                              Colors
                                  .white,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}