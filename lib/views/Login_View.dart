import 'package:codex_firebase/views/reg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/MainWrapper.dart';
import 'package:codex_firebase/views/Register_view.dart';
import 'package:codex_firebase/views/Forget_Password_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

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

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح. يرجى إدخال بريد إلكتروني صحيح.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني.';
      case 'user-not-found':
        return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'too-many-requests':
        return 'تم إرسال العديد من المحاولات الفاشلة. حاول لاحقاً.';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت ثم حاول مرة أخرى.';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      default:
        return 'حدث خطأ غير متوقع.';
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('الرجاء إدخال البريد الإلكتروني');
      return;
    }

    if (password.isEmpty) {
      _showError('الرجاء إدخال كلمة المرور');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userVm = Provider.of<User_Vm>(context, listen: false);

      final user = await userVm.login(email, password);

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      } else if (mounted) {
        String errorMsg = userVm.errorMessage ?? 'فشل تسجيل الدخول';

        if (errorMsg.contains('user-not-found')) {
          errorMsg = _getFirebaseErrorMessage('user-not-found');
        } else if (errorMsg.contains('wrong-password')) {
          errorMsg = _getFirebaseErrorMessage('wrong-password');
        } else if (errorMsg.contains('invalid-email')) {
          errorMsg = _getFirebaseErrorMessage('invalid-email');
        } else if (errorMsg.contains('invalid-credential')) {
          errorMsg = _getFirebaseErrorMessage('invalid-credential');
        }

        _showError(errorMsg);
      }
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('user-not-found')) {
        _showError(_getFirebaseErrorMessage('user-not-found'));
      } else if (errorMessage.contains('wrong-password')) {
        _showError(_getFirebaseErrorMessage('wrong-password'));
      } else if (errorMessage.contains('invalid-email')) {
        _showError(_getFirebaseErrorMessage('invalid-email'));
      } else if (errorMessage.contains('invalid-credential')) {
        _showError(_getFirebaseErrorMessage('invalid-credential'));
      } else if (errorMessage.contains('network')) {
        _showError(_getFirebaseErrorMessage('network-request-failed'));
      } else {
        _showError('حدث خطأ: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        backgroundColor: TColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== Header =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5DB1DF),
                      Color(0xFF429EBD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'images/logo.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'مرحباً بعودتك',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TColors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'سجل دخولك للوصول إلى منصة CODEX',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Form Card =====
              Padding(
                padding: const EdgeInsets.all(TSizes.lg),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: TSizes.fontSizeLg + 4,
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ===== Email =====
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'البريد الإلكتروني',
                          hintTextDirection: TextDirection.rtl,
                          filled: true,
                          fillColor: const Color(0xFFF4F8FB),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF429EBD),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF5DB1DF),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ===== Password =====
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          hintTextDirection: TextDirection.rtl,
                          filled: true,
                          fillColor: const Color(0xFFF4F8FB),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF429EBD),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF5DB1DF),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ===== Forget Password =====
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgetPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: Color(0xFF429EBD),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ===== Login Button =====
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB1DF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: TColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'الدخول',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ليس لديك حساب؟',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'إنشاء حساب',
                              style: TextStyle(
                                color: Color(0xFF429EBD),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}