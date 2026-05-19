import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  static const Color _primaryBlue = Color(0xFF429EBD);

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User_Vm>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  Future<void> _saveChanges() async {
    final loc =
        Provider.of<Language_Vm>(context, listen: false).localization;
    final userVm = Provider.of<User_Vm>(context, listen: false);
    final currentUser = userVm.currentUser;

    final Map<String, dynamic> updates = {};
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    if (newName.isNotEmpty && newName != currentUser?.name) {
      updates['name'] = newName;
    }
    if (newPhone.isNotEmpty && newPhone != (currentUser?.phone ?? '')) {
      updates['phone'] = newPhone;
    }

    if (updates.isEmpty) {
      _showSnackBar(loc.noChanges,
          color: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await userVm.updateUser(updates);
      if (mounted) {
        if (result != null) {
          _showSnackBar(loc.updatedSuccessfully,
              color: Colors.green);
          Navigator.pop(context);
        } else {
          _showSnackBar(
            userVm.errorMessage ?? loc.updateError,
            color: TColors.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('${loc.errorOccurred}: $e',
            color: TColors.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;
    final user =
        Provider.of<User_Vm>(context, listen: false).currentUser;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // ✅ نفس الخلفية الزرقاء كـ LoginScreen
      backgroundColor: _primaryBlue,
      body: Column(
        children: [
          // ══════════════════════════════════════
          // HEADER
          // ══════════════════════════════════════
          SizedBox(
            height: size.height * 0.28,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // زر الرجوع
                  Positioned(
                    top: 4,
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

                  // المحتوى
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.15),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            // ✅ زر الكاميرا
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _primaryBlue,
                                      width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 14,
                                  color: _primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          user?.name ?? loc.username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
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
                color: isDark ? TColors.dark : const Color(0xFFF5FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان القسم — نفس أسلوب ProfileScreen
                    Text(
                      loc.personalData,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? TColors.grey
                            : Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ✅ حقل الاسم
                    _buildTextField(
                      controller: _nameController,
                      hint: loc.fullName,
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 14),

                    // ✅ حقل الهاتف
                    _buildTextField(
                      controller: _phoneController,
                      hint: loc.phone,
                      icon: Icons.phone_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 28),

                    // ✅ معلومات ثابتة (غير قابلة للتعديل)
                    Text(
                      'معلومات الحساب',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? TColors.grey
                            : Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildReadOnlyField(
                      isDark: isDark,
                      label: 'البريد الإلكتروني',
                      value: user?.email ?? '—',
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 32),

                    // ✅ زر الحفظ — نفس أسلوب Login button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveChanges,
                        icon: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Icon(Icons.save_rounded,
                            color: Colors.white),
                        label: Text(
                          _isLoading ? '...' : loc.saveChanges,
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
  // WIDGETS
  // ──────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 15,
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
          borderSide: BorderSide(
            color: _primaryBlue.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  // ✅ حقل للعرض فقط (مثل الإيميل)
  Widget _buildReadOnlyField({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? TColors.darkerGrey.withOpacity(0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? TColors.grey.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isDark
                  ? TColors.grey
                  : Colors.grey.shade400,
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? TColors.grey
                    : Colors.grey.shade500,
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'لا يمكن تعديله',
              style: TextStyle(
                fontSize: 10,
                color: _primaryBlue.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}