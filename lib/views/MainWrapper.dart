import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';

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
  int _currentIndex = 4;

  final List<Widget> _pages = [
    const AdsScreen(),
    const StoreScreen(),
    const ConsultationsScreen(),
    const ProfileScreen(),
    const HomeScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      "icon": Icons.campaign_rounded,
      "label": "إعلانات",
    },
    {
      "icon": Icons.shopping_bag_rounded,
      "label": "متجر",
    },
    {
      "icon": Icons.chat_bubble_rounded,
      "label": "استشارة",
    },
    {
      "icon": Icons.person_rounded,
      "label": "الحساب",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;

    const Color primaryBlue = Color(0xFF5DB1DF);

    final Color backgroundColor =
    isDark ? const Color(0xFF0F172A) : const Color(0xFFF5FAFD);

    final Color navBarColor =
    isDark ? const Color(0xFF1E293B) : Colors.white;

    final Color selectedColor = primaryBlue;

    final Color unselectedColor =
    isDark ? Colors.white54 : Colors.grey.shade500;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ================= BODY =================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pages[_currentIndex],
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 18,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: navBarColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
                (index) {
              final bool isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryBlue.withOpacity(
                        isDark ? 0.18 : 0.12,
                      )
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _navItems[index]["icon"],
                            color: isSelected
                                ? Colors.white
                                : unselectedColor,
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: 6),

                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: isSelected ? 13 : 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? selectedColor
                                : unselectedColor,
                          ),
                          child: Text(
                            _navItems[index]["label"],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}