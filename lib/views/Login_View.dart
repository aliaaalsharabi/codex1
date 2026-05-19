import 'package:codex_firebase/views/reg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/MainWrapper.dart';
import 'package:codex_firebase/views/Register_view.dart';
import 'package:codex_firebase/views/Forget_Password_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getFirebaseErrorMessage(String errorCode) {
    final loc = Provider.of<Language_Vm>(context, listen: false).localization;
    switch (errorCode) {
      case 'invalid-email':          return loc.errorInvalidEmail;
      case 'user-disabled':          return loc.errorUserDisabled;
      case 'user-not-found':         return loc.errorUserNotFound;
      case 'wrong-password':         return loc.errorWrongPassword;
      case 'too-many-requests':      return loc.errorTooManyRequests;
      case 'network-request-failed': return loc.errorNetwork;
      case 'invalid-credential':     return loc.errorInvalidCredential;
      default:                       return loc.errorUnexpected;
    }
  }

  Future<void> _handleLogin() async {
    final loc = Provider.of<Language_Vm>(context, listen: false).localization;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty)    { _showError(loc.pleaseEnterEmail);    return; }
    if (password.isEmpty) { _showError(loc.pleaseEnterPassword); return; }

    setState(() => _isLoading = true);
    try {
      final userVm = Provider.of<User_Vm>(context, listen: false);
      final user = await userVm.login(email, password);

      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
      } else if (mounted) {
        String errorMsg = userVm.errorMessage ?? loc.loginFailed;
        if (errorMsg.contains('user-not-found'))        errorMsg = _getFirebaseErrorMessage('user-not-found');
        else if (errorMsg.contains('wrong-password'))   errorMsg = _getFirebaseErrorMessage('wrong-password');
        else if (errorMsg.contains('invalid-email'))    errorMsg = _getFirebaseErrorMessage('invalid-email');
        else if (errorMsg.contains('invalid-credential')) errorMsg = _getFirebaseErrorMessage('invalid-credential');
        _showError(errorMsg);
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('user-not-found'))         _showError(_getFirebaseErrorMessage('user-not-found'));
      else if (msg.contains('wrong-password'))    _showError(_getFirebaseErrorMessage('wrong-password'));
      else if (msg.contains('invalid-email'))     _showError(_getFirebaseErrorMessage('invalid-email'));
      else if (msg.contains('invalid-credential')) _showError(_getFirebaseErrorMessage('invalid-credential'));
      else if (msg.contains('network'))           _showError(_getFirebaseErrorMessage('network-request-failed'));
      else _showError('${loc.errorUnexpected}: $msg');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: TColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(14),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<Language_Vm>();
    final loc = langVm.localization;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF429EBD), // ✅ خلفية زرقاء للأعلى
      body: Column(
        children: [

          // ===== HEADER — يأخذ 38% من الشاشة =====
          SizedBox(
            height: size.height * 0.38,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اللوجو
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset('images/logo.jpg', fit: BoxFit.contain),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    loc.welcomeBack,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    loc.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== FORM — بقية الشاشة =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5FAFD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // عنوان
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        loc.login,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF429EBD),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== Email =====
                    _buildTextField(
                      controller: _emailController,
                      hint: loc.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    // ===== Password =====
                    _buildTextField(
                      controller: _passwordController,
                      hint: loc.password,
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // ===== Forget Password =====
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        ),
                        child: Text(
                          loc.forgetPassword,
                          style: const TextStyle(
                            color: Color(0xFF429EBD),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== Login Button =====
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF429EBD),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
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
                          loc.login,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== No Account — سطر واحد =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loc.noAccount,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: Text(
                            loc.createAccount,
                            style: const TextStyle(
                              color: Color(0xFF429EBD),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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
        prefixIcon: Icon(icon, color: const Color(0xFF429EBD), size: 20),
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
          borderSide: const BorderSide(color: Color(0xFF429EBD), width: 1.5),
        ),
      ),
    );
  }
}