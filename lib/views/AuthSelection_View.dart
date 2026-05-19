import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/Register_view.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF429EBD);
    final langVm = context.watch<Language_Vm>(); // ✅ watch
    final loc = langVm.localization;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: Stack(
        children: [

          // ===== الخلفية العلوية — فلات بدون gradient =====
          Container(
            height: size.height * 0.40,
            width: double.infinity,
            color: primaryBlue,
          ),

          // ===== زخارف دوائر خفيفة =====
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.15,
            left: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // ===== زر اللغة — أعلى يسار =====
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd, // ✅ يتكيف مع RTL/LTR
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.language_rounded, color: Colors.white),
                    onPressed: () => _showLanguageDialog(context, langVm),
                  ),
                ),
              ),
            ),
          ),

          // ===== المحتوى الرئيسي =====
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    // ✅ ظل خفيف
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ===== اللوجو — مربع فلات =====
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FD),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.15),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset('images/logo.jpg', fit: BoxFit.contain),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ===== العنوان =====
                      Text(
                        loc.welcomeToCodex,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E3B),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        loc.authSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.7,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ===== زر الدخول =====
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0, // ✅ فلات
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                loc.login,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== زر التسجيل =====
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryBlue.withOpacity(0.35), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: primaryBlue.withOpacity(0.04),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded, color: primaryBlue, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                loc.register,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ===== Footer =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 30, height: 1.5, color: Colors.grey.shade200),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Codex Platform',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(width: 30, height: 1.5, color: Colors.grey.shade200),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, Language_Vm langVm) {
    final loc = langVm.localization;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          loc.selectLanguage,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageTile(
              icon: Icons.computer_rounded,
              label: loc.systemDefault,
              isSelected: langVm.currentLanguage == AppLanguage.system,
              onTap: () {
                langVm.setLanguage(AppLanguage.system);
                Navigator.pop(dialogContext);
              },
            ),
            _LanguageTile(
              icon: Icons.language_rounded,
              label: 'العربية',
              isSelected: langVm.currentLanguage == AppLanguage.arabic,
              onTap: () {
                langVm.setLanguage(AppLanguage.arabic);
                Navigator.pop(dialogContext);
              },
            ),
            _LanguageTile(
              icon: Icons.language_rounded,
              label: 'English',
              isSelected: langVm.currentLanguage == AppLanguage.english,
              onTap: () {
                langVm.setLanguage(AppLanguage.english);
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Widget مساعد لعناصر اللغة =====
class _LanguageTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF429EBD);
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryBlue : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? primaryBlue : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: primaryBlue)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? primaryBlue.withOpacity(0.06) : null,
      onTap: onTap,
    );
  }
}