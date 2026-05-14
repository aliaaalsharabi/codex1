import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart'; // تأكدي من المسار الصحيح للثيم
import 'package:codex_firebase/constants/colors.dart';   // تأكدي من المسار الصحيح للثوابت
import 'home_screen.dart';
import 'store_screen.dart';
import 'consultations_screen.dart';
import 'profile_screen.dart';
import 'ads_screen.dart';

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
    // التحقق من حالة الوضع الليلي
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;

    // الألوان المتغيرة بناءً على الوضع
    final Color brandColor = const Color(0xFF5DB1DF);
    final Color scaffoldBg = isDark ? TColors.dark : TColors.white;
    final Color navBarBg = isDark ? TColors.darkerGrey : brandColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: _currentIndex == 4
          ? null
          : AppBar(
        backgroundColor: navBarBg,
        elevation: 0,
        title: Text(
          "CODEX",
          style: TextStyle(color: isDark ? TColors.white : Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.home, color: isDark ? TColors.white : Colors.white),
          onPressed: () => setState(() => _currentIndex = 4),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex == 4 ? 0 : _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: navBarBg,
        selectedItemColor: isDark ? TColors.primary : Colors.white,
        unselectedItemColor: isDark ? TColors.grey : Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'إعلانات'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'متجر'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'استشارة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
      ),
    );
  }
}