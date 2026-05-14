import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/Edit_Profile_screen.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart'; // ✅ أضفت ملف الثيم
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userVm = Provider.of<User_Vm>(context, listen: false);
    await userVm.fetchCurrentUser();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout(bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? TColors.darkerGrey : TColors.white, // ✅ لون الخلفية
        title: Text('تسجيل الخروج', style: TextStyle(color: isDark ? TColors.white : TColors.black)),
        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', style: TextStyle(color: isDark ? TColors.grey : TColors.darkGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: isDark ? TColors.grey : TColors.darkGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج', style: TextStyle(color: TColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userVm = Provider.of<User_Vm>(context, listen: false);
      await userVm.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة حالة الثيم
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white, // ✅ لون الخلفية الأساسي
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TColors.primary))
          : Consumer<User_Vm>(
        builder: (context, vm, child) {
          final user = vm.currentUser;
          return Column(
            children: [
              // الحاوية العلوية (Header)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  // ✅ جعل اللون أغمق قليلاً في الوضع الليلي
                  color: isDark ? const Color(0xFF1F4E68) : const Color(0xFF5DB1DF),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(TSizes.cardRaduisLg),
                    bottomRight: Radius.circular(TSizes.cardRaduisLg),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: TSizes.md),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? TColors.darkerGrey : TColors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: isDark ? TColors.grey : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      user?.name ?? 'اسم المستخدم',
                      style: const TextStyle(
                        color: TColors.white,
                        fontSize: TSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: TextStyle(
                          color: TColors.white.withOpacity(0.7),
                          fontSize: TSizes.fontSizeSm,
                        ),
                      ),
                  ],
                ),
              ),

              // قائمة الخيارات
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(TSizes.md),
                  children: [
                    _buildProfileOption(
                        'تعديل الملف الشخصي',
                        Icons.edit,
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        }
                    ),
                    _buildProfileOption('عناويني', Icons.location_on, isDark: isDark),
                    _buildProfileOption('طلباتي', Icons.shopping_bag, isDark: isDark),
                    _buildProfileOption('الإعدادات', Icons.settings, isDark: isDark),

                    Divider(
                        height: TSizes.spaceBtwSections,
                        color: isDark ? Colors.white10 : Colors.grey[200]
                    ),

                    _buildProfileOption(
                      'تسجيل الخروج',
                      Icons.logout,
                      isDark: isDark,
                      textColor: TColors.error,
                      onTap: () => _handleLogout(isDark),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ تعديل ودجت الخيارات لتدعم الثيم
  Widget _buildProfileOption(
      String title,
      IconData icon,
      {required bool isDark, VoidCallback? onTap, Color? textColor}) {

    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      decoration: BoxDecoration(
        // ✅ تغيير لون خلفية الخيار
        color: isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA),
        borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: ListTile(
        leading: Icon(
            icon,
            color: isDark ? TColors.accent : const Color(0xFF429EBD)
        ),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            // ✅ تغيير لون النص
            color: textColor ?? (isDark ? TColors.white : TColors.textprimary),
          ),
        ),
        trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? TColors.grey : TColors.darkGrey
        ),
        onTap: onTap,
      ),
    );
  }
}