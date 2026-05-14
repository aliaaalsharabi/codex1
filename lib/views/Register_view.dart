import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/MainWrapper.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'coder';

  // ✅ دالة لترجمة رسائل Firebase للتسجيل
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى استخدام بريد آخر أو تسجيل الدخول.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح. يرجى إدخال بريد إلكتروني صحيح.';
      case 'operation-not-allowed':
        return 'عذراً، خدمة التسجيل غير متاحة حالياً. يرجى المحاولة لاحقاً.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً. يرجى استخدام كلمة مرور أقوى (6 أحرف على الأقل).';
      case 'network-request-failed':
        return 'حدث خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك ومحاولة مرة أخرى.';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              color: const Color(0xFF5DB1DF),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.12,
                left: TSizes.md,
                right: TSizes.md,
                bottom: TSizes.md,
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
              child: Consumer<User_Vm>(
                builder: (context, userVm, child) {
                  return Column(
                    children: [
                      const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontSize: TSizes.fontSizeLg + 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF429EBD),
                        ),
                      ),
                      const SizedBox(height: TSizes.md),
                      _buildTextField('الاسم', Icons.person, _nameController),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      _buildTextField(
                        'البريد الإلكتروني',
                        Icons.email,
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      _buildTextField(
                        'رقم الهاتف (اختياري)',
                        Icons.phone,
                        _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      _buildDropdown(),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      _buildPasswordField(
                        'كلمة المرور',
                        _passwordController,
                        _obscurePassword,
                            () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      _buildPasswordField(
                        'تأكيد كلمة المرور',
                        _confirmPasswordController,
                        _obscureConfirmPassword,
                            () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      SizedBox(
                        width: double.infinity,
                        height: TSizes.buttonHeight + 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB1DF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _handleRegister(userVm),
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
                            'التسجيل',
                            style: TextStyle(
                              fontSize: TSizes.fontSizeMd,
                              color: TColors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(color: Color(0xFF429EBD)),
                            ),
                          ),
                          const Text("لديك حساب بالفعل؟"),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: TSizes.xl,
              right: TSizes.sm,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: TColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      IconData icon,
      TextEditingController controller, {
        TextInputType? keyboardType,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon, color: const Color(0xFF429EBD)),
        filled: true,
        fillColor: const Color(0xFFF0F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRaduisSm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String hint,
      TextEditingController controller,
      bool obscure,
      VoidCallback toggle,
      ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF429EBD)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: TColors.grey),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF0F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRaduisSm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FA),
        borderRadius: BorderRadius.circular(TSizes.borderRaduisSm),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedUserType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: TSizes.sm),
        ),
        items: const [
          DropdownMenuItem(value: 'coder', child: Text('مبرمج')),
          DropdownMenuItem(value: 'company', child: Text('شركة')),
          DropdownMenuItem(value: 'vendor', child: Text('بائع')),
          DropdownMenuItem(value: 'consultant', child: Text('مستشار')),
        ],
        onChanged: (value) => setState(() => _selectedUserType = value!),
      ),
    );
  }

  Future<void> _handleRegister(User_Vm userVm) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showError('الرجاء إدخال الاسم');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('الرجاء إدخال بريد إلكتروني صحيح');
      return;
    }
    if (password.isEmpty) {
      _showError('الرجاء إدخال كلمة المرور');
      return;
    }
    if (password.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (password != confirmPassword) {
      _showError('كلمة المرور غير متطابقة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = {
        'name': name,
        'email': email,
        'password': password,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'user_type': _selectedUserType,
      };
      final user = await userVm.register(userData);
      if (user != null && mounted) {
        _showSuccess('تم إنشاء الحساب بنجاح');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      } else if (mounted) {
        String errorMsg = userVm.errorMessage ?? 'فشل إنشاء الحساب';

        // ✅ ترجمة رسائل Firebase للتسجيل
        if (errorMsg.contains('email-already-in-use')) {
          errorMsg = _getFirebaseErrorMessage('email-already-in-use');
        } else if (errorMsg.contains('weak-password')) {
          errorMsg = _getFirebaseErrorMessage('weak-password');
        } else if (errorMsg.contains('invalid-email')) {
          errorMsg = _getFirebaseErrorMessage('invalid-email');
        }

        _showError(errorMsg);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('email-already-in-use')) {
        _showError(_getFirebaseErrorMessage('email-already-in-use'));
      } else if (errorMessage.contains('weak-password')) {
        _showError(_getFirebaseErrorMessage('weak-password'));
      } else if (errorMessage.contains('invalid-email')) {
        _showError(_getFirebaseErrorMessage('invalid-email'));
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: TColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}