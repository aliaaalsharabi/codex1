import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/Edit_Profile_screen.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/modelview/language_vm.dart';
import 'package:codex_firebase/constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  static const Color _primaryBlue = Color(0xFF429EBD);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await Provider.of<User_Vm>(context, listen: false).fetchCurrentUser();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleLogout(bool isDark) async {
    final loc = Provider.of<Language_Vm>(context, listen: false).localization;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? TColors.darkerGrey : TColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.logout,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(loc.areYouSure),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel,
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(loc.exit),
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
      backgroundColor: _primaryBlue,
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.white))
          : Consumer<User_Vm>(
        builder: (context, vm, _) {
          final user = vm.currentUser;
          final loc = Provider.of<Language_Vm>(context).localization;

          return Column(
            children: [
              _buildHeader(isDark, user, loc),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? TColors.dark
                        : const Color(0xFFF5FAFD),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                    const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      children: [
                        _buildAccountInfoCard(isDark, loc),
                        const SizedBox(height: 20),
                        _buildSectionLabel('الحساب', isDark),
                        const SizedBox(height: 10),
                        _buildMenuItem(
                          isDark: isDark,
                          title: loc.editProfile,
                          icon: Icons.edit_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const EditProfileScreen()),
                          ),
                        ),
                        _buildMenuItem(
                          isDark: isDark,
                          title: loc.myOrders,
                          icon: Icons.shopping_bag_outlined,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          isDark: isDark,
                          title: loc.myAddresses,
                          icon: Icons.location_on_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                        _buildSectionLabel('الإعدادات', isDark),
                        const SizedBox(height: 10),
                        _buildToggleItem(
                          isDark: isDark,
                          title: 'الوضع الداكن',
                          icon: isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          value: isDark,
                          onChanged: (_) {
                            Provider.of<Theme_Vm>(context,
                                listen: false)
                                .toggleTheme();
                          },
                        ),
                        _buildMenuItem(
                          isDark: isDark,
                          title: loc.language,
                          icon: Icons.language_outlined,
                          trailing: _buildLangBadge(context, isDark),
                          onTap: () => _showLanguageDialog(context),
                        ),
                        _buildMenuItem(
                          isDark: isDark,
                          title: loc.settings,
                          icon: Icons.settings_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleLogout(isDark),
                            icon: const Icon(Icons.logout_outlined),
                            label: Text(
                              loc.logout,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.red.withOpacity(0.1),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                side: BorderSide(
                                    color:
                                    Colors.red.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'الإصدار 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? TColors.grey
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────

  Widget _buildHeader(bool isDark, dynamic user, dynamic loc) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Icon(
                      Icons.person,
                      size: 42,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                // نقطة متصل
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: _primaryBlue, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // الاسم والإيميل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

            // زر التعديل
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditProfileScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // ACCOUNT INFO CARD
  // ──────────────────────────────────────────

  Widget _buildAccountInfoCard(bool isDark, dynamic loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
              isDark: isDark,
              label: loc.myOrders,
              value: '0',
              icon: Icons.shopping_bag_outlined),
          _buildDivider(isDark),
          _buildStatItem(
              isDark: isDark,
              label: 'المراجعات',
              value: '0',
              icon: Icons.star_outline),
          _buildDivider(isDark),
          _buildStatItem(
              isDark: isDark,
              label: 'المفضلة',
              value: '0',
              icon: Icons.favorite_outline),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _primaryBlue, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? TColors.grey : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 50,
      color:
      isDark ? TColors.grey.withOpacity(0.2) : Colors.grey.shade200,
    );
  }

  // ──────────────────────────────────────────
  // MENU ITEMS
  // ──────────────────────────────────────────

  Widget _buildSectionLabel(String label, bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? TColors.grey : Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required bool isDark,
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    String? badge,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryBlue, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? TColors.white : Colors.black87,
          ),
        ),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.arrow_back_ios,
                  size: 14,
                  color:
                  isDark ? TColors.grey : Colors.grey.shade400,
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildToggleItem({
    required bool isDark,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryBlue, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? TColors.white : Colors.black87,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: _primaryBlue,
        ),
      ),
    );
  }

  Widget _buildLangBadge(BuildContext context, bool isDark) {
    final langVm = Provider.of<Language_Vm>(context);
    final label = langVm.currentLanguage == AppLanguage.arabic
        ? 'ع'
        : langVm.currentLanguage == AppLanguage.english
        ? 'EN'
        : 'Auto';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_back_ios,
            size: 14,
            color: isDark ? TColors.grey : Colors.grey.shade400),
      ],
    );
  }

  // ──────────────────────────────────────────
  // LANGUAGE DIALOG
  // ──────────────────────────────────────────

  void _showLanguageDialog(BuildContext context) {
    final langVm =
    Provider.of<Language_Vm>(context, listen: false);
    final isDark =
        Provider.of<Theme_Vm>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        isDark ? TColors.darkerGrey : TColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          langVm.localization.selectLanguage,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangOption(
              langVm: langVm,
              label: langVm.localization.systemDefault,
              icon: Icons.computer_outlined,
              lang: AppLanguage.system,
            ),
            _buildLangOption(
              langVm: langVm,
              label: 'العربية',
              icon: Icons.language,
              lang: AppLanguage.arabic,
            ),
            _buildLangOption(
              langVm: langVm,
              label: 'English',
              icon: Icons.language,
              lang: AppLanguage.english,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption({
    required Language_Vm langVm,
    required String label,
    required IconData icon,
    required AppLanguage lang,
  }) {
    final isSelected = langVm.currentLanguage == lang;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? _primaryBlue : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight:
          isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? _primaryBlue : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: _primaryBlue)
          : null,
      onTap: () {
        langVm.setLanguage(lang);
        Navigator.pop(context);
      },
    );
  }
}