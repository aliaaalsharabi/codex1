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

  // ✅ دالة لترجمة رسائل Firebase إلى العربية
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح. يرجى إدخال بريد إلكتروني صحيح.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني.';
      case 'user-not-found':
        return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني. يرجى التحقق من البريد أو إنشاء حساب جديد.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';
      case 'too-many-requests':
        return 'تم إرسال العديد من المحاولات الفاشلة. يرجى المحاولة لاحقاً.';
      case 'network-request-failed':
        return 'حدث خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك ومحاولة مرة أخرى.';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.';
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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainWrapper()),
          );
        }
      } else if (mounted) {
        // ✅ ترجمة رسالة الخطأ إذا كانت من Firebase
        String errorMsg = userVm.errorMessage ?? 'فشل تسجيل الدخول';

        // التحقق إذا كان الخطأ من Firebase Auth
        if (errorMsg.contains('user-not-found') ||
            errorMsg.contains('wrong-password') ||
            errorMsg.contains('invalid-email') ||
            errorMsg.contains('invalid-credential')) {
          errorMsg = _getFirebaseErrorMessage(errorMsg);
        }

        _showError(errorMsg);
      }
    } catch (e) {
      String errorMessage = e.toString();
      // استخراج رمز الخطأ من رسالة Firebase
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
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: TColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              color: const Color(0xFF5DB1DF),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.2,
                left: TSizes.md,
                right: TSizes.md,
                bottom: TSizes.xl,
              ),
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(TSizes.cardRaduisLg),
                boxShadow: [
                  BoxShadow(
                    color: TColors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'الدخول',
                    style: TextStyle(
                      fontSize: TSizes.fontSizeLg + 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF429EBD),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  TextField(
                    controller: _emailController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'البريد الإلكتروني',
                      hintTextDirection: TextDirection.rtl,
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF429EBD)),
                      filled: true,
                      fillColor: const Color(0xFFF0F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      hintTextDirection: TextDirection.rtl,
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF429EBD)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: TColors.grey,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen(),
                        ),
                      ),
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(color: TColors.info),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.md),
                  SizedBox(
                    width: double.infinity,
                    height: TSizes.buttonHeight + 37,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DB1DF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                        height: TSizes.LoadingIndicatorSize,
                        width: TSizes.LoadingIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TColors.white,
                        ),
                      )
                          : const Text(
                        'الدخول',
                        style: TextStyle(
                          fontSize: TSizes.fontSizeLg,
                          color: TColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color: Color(0xFF429EBD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text("ليس لديك حساب؟"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}