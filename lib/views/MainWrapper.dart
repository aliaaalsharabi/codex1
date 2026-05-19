import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/language_vm.dart';
import 'home_screen.dart';
import 'store_screen.dart';
import 'consultations_screen.dart';
import 'profile_screen.dart';
import 'ads_screen.dart';

const Color _primary = Color(0xFF429EBD);

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdsScreen(),
    const StoreScreen(),
    const ConsultationsScreen(),
    const ProfileScreen(),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<Theme_Vm>().isDarkMode;
    final loc    = context.watch<Language_Vm>().localization;

    final Color scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5FAFD);
    final Color navBg      = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    // عناوين الصفحات
    final titles = [loc.navAds, loc.navStore, loc.navConsultation, loc.navProfile];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: scaffoldBg,

        // ===== AppBar — نفس ستايل باقي الشاشات =====
        appBar: _currentIndex == 4
            ? null
            : AppBar(
          backgroundColor: _primary,
          elevation: 0,
          centerTitle: true,

          // اسم التطبيق — نفس ستايل WelcomeScreen
          title: Text(
            loc.appName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),

          // زر الهوم — نفس ستايل زر التخطي في Onboarding
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.home_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => setState(() => _currentIndex = 4),
                ),
              ),
            ),
          ],

          // عنوان الصفحة الحالية
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                titles[_currentIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),

        // ===== Body =====
        body: _pages[_currentIndex],

        // ===== BottomNav — أبيض منفصل عن AppBar =====
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.announcement_outlined,
                    activeIcon: Icons.announcement_rounded,
                    label: loc.navAds,
                    isActive: _currentIndex == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag_rounded,
                    label: loc.navStore,
                    isActive: _currentIndex == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Icons.chat_outlined,
                    activeIcon: Icons.chat_rounded,
                    label: loc.navConsultation,
                    isActive: _currentIndex == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: loc.navProfile,
                    isActive: _currentIndex == 3,
                    isDark: isDark,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Custom Nav Item =====
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor   = _primary;
    final Color inactiveColor = isDark ? Colors.white38 : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}