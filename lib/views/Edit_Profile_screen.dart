import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart'; // ✅ أضفت ملف الثيم
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userVm = Provider.of<User_Vm>(context, listen: false);
    final user = userVm.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final Map<String, dynamic> updates = {};
    final currentUser = Provider.of<User_Vm>(context, listen: false).currentUser;

    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != currentUser?.name) {
      updates['name'] = newName;
    }

    final newPhone = _phoneController.text.trim();
    if (newPhone.isNotEmpty && newPhone != (currentUser?.phone ?? '')) {
      updates['phone'] = newPhone;
    }

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد تغييرات لحفظها')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userVm = Provider.of<User_Vm>(context, listen: false);
      final result = await userVm.updateUser(updates);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userVm.errorMessage ?? 'حدث خطأ أثناء التحديث'), backgroundColor: TColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}'), backgroundColor: TColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة حالة الثيم
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;

    // إعدادات ألوان الحقول بناءً على الثيم
    final fieldFillColor = isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA);
    final textStyle = TextStyle(color: isDark ? TColors.white : TColors.black);
    final iconColor = isDark ? TColors.accent : const Color(0xFF429EBD);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView( // أضفت Scroller لتجنب مشاكل لوحة المفاتيح
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),

            // حقل الاسم
            TextField(
              controller: _nameController,
              textAlign: TextAlign.right,
              style: textStyle,
              decoration: InputDecoration(
                hintText: 'الاسم',
                hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: fieldFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.person, color: iconColor),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // حقل رقم الهاتف
            TextField(
              controller: _phoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              style: textStyle,
              decoration: InputDecoration(
                hintText: 'رقم الهاتف',
                hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: fieldFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.phone, color: iconColor),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // زر حفظ التغييرات
            SizedBox(
              width: double.infinity,
              height: 55, // ارتفاع ثابت ومناسب
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                  ),
                ),
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TColors.white,
                  ),
                )
                    : const Text(
                  'حفظ التغييرات',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeMd,
                    color: TColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}