import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/Edit_Profile_screen.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/views/home_screen.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
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
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleLogout(bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? TColors.darkerGrey : TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('تسجيل الخروج', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'خروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<User_Vm>(context, listen: false).logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : const Color(0xFFF7FAFC),

      // ⭐ زر Home العائم (حل مشكلتك)
      // floatingActionButton: FloatingActionButton(
      //   heroTag: "home_btn",
      //   backgroundColor: const Color(0xFF5DB1DF),
      //   mini: true,
      //   onPressed: () {
      //     Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (_) => const HomeScreen()),
      //           (route) => false,
      //     );
      //   },
      //   child: const Icon(Icons.home, color: Colors.white),
      // ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<User_Vm>(
        builder: (context, vm, child) {
          final user = vm.currentUser;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: const Color(0xFF5DB1DF),
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF5DB1DF),
                              Color(0xFF429EBD),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person,
                                    size: 55,
                                    color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                user?.name ?? "اسم المستخدم",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (user?.email != null)
                                Text(
                                  user!.email,
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _cardItem(
                            title: "تعديل الملف الشخصي",
                            icon: Icons.edit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          _cardItem(
                            title: "عناويني",
                            icon: Icons.location_on,
                          ),
                          _cardItem(
                            title: "طلباتي",
                            icon: Icons.shopping_bag,
                          ),
                          _cardItem(
                            title: "الإعدادات",
                            icon: Icons.settings,
                          ),

                          const SizedBox(height: 10),

                          _cardItem(
                            title: "تسجيل الخروج",
                            icon: Icons.logout,
                            color: Colors.red,
                            onTap: () => _handleLogout(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ⭐ زر Home العلوي (اللي طلبته فوق الشاشة)
              Positioned(
                top: 50,
                right: 15,
                child: SafeArea(
                  child: FloatingActionButton(
                    heroTag: "top_home",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                            (route) => false,
                      );
                    },
                    child: const Icon(Icons.home,
                        color: Color(0xFF5DB1DF)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cardItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? const Color(0xFF5DB1DF)),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_back_ios, size: 16),
      ),
    );
  }
}