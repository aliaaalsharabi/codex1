import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/MainWrapper.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/language_vm.dart';
import 'package:codex_firebase/l10n/app_localization.dart';

const Color _primary = Color(0xFF429EBD);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController        = TextEditingController();
  final _emailController       = TextEditingController();
  final _phoneController       = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmController     = TextEditingController();

  bool _isLoading              = false;
  bool _obscurePassword        = true;
  bool _obscureConfirm         = true;
  String _selectedUserType     = 'coder';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _getFirebaseErrorMessage(String code) {
    final loc = Provider.of<Language_Vm>(context, listen: false).localization;
    switch (code) {
      case 'email-already-in-use': return loc.errorEmailInUse;
      case 'invalid-email':        return loc.errorInvalidEmail;
      case 'weak-password':        return loc.errorWeakPassword;
      case 'network-request-failed': return loc.errorNetwork;
      default:                     return loc.errorUnexpected;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: TColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(14),
    ));
  }

  Future<void> _handleRegister(User_Vm userVm) async {
    final loc  = Provider.of<Language_Vm>(context, listen: false).localization;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    if (name.isEmpty)     { _showError(loc.pleaseEnterEmail); return; }
    if (email.isEmpty)    { _showError(loc.pleaseEnterEmail); return; }
    if (password.isEmpty) { _showError(loc.pleaseEnterPassword); return; }
    if (password != confirm) { _showError(loc.passwordsNotMatch); return; }

    setState(() => _isLoading = true);
    try {
      final user = await userVm.register({
        "name": name,
        "email": email,
        "password": password,
        "phone": _phoneController.text,
        "user_type": _selectedUserType,
      });
      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('email-already-in-use'))    _showError(_getFirebaseErrorMessage('email-already-in-use'));
      else if (msg.contains('invalid-email'))      _showError(_getFirebaseErrorMessage('invalid-email'));
      else if (msg.contains('weak-password'))      _showError(_getFirebaseErrorMessage('weak-password'));
      else if (msg.contains('network'))            _showError(_getFirebaseErrorMessage('network-request-failed'));
      else _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<Language_Vm>();
    final loc    = langVm.localization;
    final size   = MediaQuery.of(context).size;
    final isRTL  = langVm.textDirection == TextDirection.rtl;

    return Scaffold(
      backgroundColor: _primary,
      body: Column(
        children: [

          // ===== HEADER =====
          SizedBox(
            height: size.height * 0.22,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // زر الرجوع
                  Positioned(
                    top: 4,
                    right: isRTL ? 8 : null,
                    left: isRTL ? null : 8,
                    child: IconButton(
                      icon: Icon(
                        isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // العنوان
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Icon(Icons.person_add_alt_1_rounded,
                            color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          loc.createNewAccount,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== FORM =====
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5FAFD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Consumer<User_Vm>(
                  builder: (context, userVm, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // ===== الحقول =====
                        _buildTextField(
                          controller: _nameController,
                          hint: loc.name,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _emailController,
                          hint: loc.email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _phoneController,
                          hint: loc.phoneOptional,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        // ===== Dropdown نوع المستخدم =====
                        _buildDropdown(loc),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _passwordController,
                          hint: loc.password,
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _confirmController,
                          hint: loc.confirmPassword,
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ===== Register Button =====
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isLoading ? null : () => _handleRegister(userVm),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(
                              loc.register,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ===== Already have account — سطر واحد =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.alreadyHaveAccount,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              ),
                              child: Text(
                                loc.loginNow,
                                style: const TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TextField موحد =====
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: _primary, size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  // ===== Dropdown =====
  Widget _buildDropdown(AppLocalization loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUserType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          items: [
            DropdownMenuItem(
              value: 'coder',
              child: Row(children: [
                const Icon(Icons.code_rounded, color: _primary, size: 18),
                const SizedBox(width: 10),
                Text(loc.coder),
              ]),
            ),
            DropdownMenuItem(
              value: 'company',
              child: Row(children: [
                const Icon(Icons.business_rounded, color: _primary, size: 18),
                const SizedBox(width: 10),
                Text(loc.company),
              ]),
            ),
            DropdownMenuItem(
              value: 'vendor',
              child: Row(children: [
                const Icon(Icons.store_rounded, color: _primary, size: 18),
                const SizedBox(width: 10),
                Text(loc.vendor),
              ]),
            ),
            DropdownMenuItem(
              value: 'consultant',
              child: Row(children: [
                const Icon(Icons.support_agent_rounded, color: _primary, size: 18),
                const SizedBox(width: 10),
                Text(loc.consultant),
              ]),
            ),
          ],
          onChanged: (value) => setState(() => _selectedUserType = value!),
        ),
      ),
    );
  }
}