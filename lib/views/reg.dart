import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/MainWrapper.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/modelview/user_vm.dart';

class RegisterScreenNew extends StatefulWidget {
  const RegisterScreenNew({super.key});

  @override
  State<RegisterScreenNew> createState() => _RegisterScreenNewState();
}

class _RegisterScreenNewState extends State<RegisterScreenNew> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _selectedUserType = 'coder';

  final Color primaryColor = const Color(0xFF4FA8D8);

  // ================= Firebase Error Messages =================

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';

      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';

      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';

      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';

      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ================= HEADER =================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      const Color(0xFF72C6EF),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [

                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "إنشاء حساب",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "قم بإنشاء حساب جديد للمتابعة",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= FORM =================

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Consumer<User_Vm>(
                    builder: (context, userVm, child) {
                      return Column(
                        children: [

                          // ================= NAME =================

                          _buildTextField(
                            controller: _nameController,
                            hint: "الاسم الكامل",
                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 18),

                          // ================= EMAIL =================

                          _buildTextField(
                            controller: _emailController,
                            hint: "البريد الإلكتروني",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 18),

                          // ================= PHONE =================

                          _buildTextField(
                            controller: _phoneController,
                            hint: "رقم الهاتف",
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 18),

                          // ================= DROPDOWN =================

                          _buildDropdown(),

                          const SizedBox(height: 18),

                          // ================= PASSWORD =================

                          _buildPasswordField(
                            controller: _passwordController,
                            hint: "كلمة المرور",
                            obscure: _obscurePassword,
                            toggle: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          // ================= CONFIRM PASSWORD =================

                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hint: "تأكيد كلمة المرور",
                            obscure: _obscureConfirmPassword,
                            toggle: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                          ),

                          const SizedBox(height: 30),

                          // ================= BUTTON =================

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () => _handleRegister(userVm),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "إنشاء الحساب",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ================= LOGIN =================

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Text(
                                "لديك حساب بالفعل؟",
                                style: TextStyle(fontSize: 15),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: const Color(0xFFF4F8FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF4F8FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUserType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4F8FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [

        DropdownMenuItem(
          value: 'coder',
          child: Text('مبرمج'),
        ),

        DropdownMenuItem(
          value: 'company',
          child: Text('شركة'),
        ),

        DropdownMenuItem(
          value: 'vendor',
          child: Text('بائع'),
        ),

        DropdownMenuItem(
          value: 'consultant',
          child: Text('مستشار'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedUserType = value!;
        });
      },
    );
  }

  // ================= REGISTER =================

  Future<void> _handleRegister(User_Vm userVm) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ================= VALIDATION =================

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
        'phone': _phoneController.text.trim(),
        'user_type': _selectedUserType,
      };

      final user = await userVm.register(userData);

      if (user != null && mounted) {

        _showSuccess('تم إنشاء الحساب بنجاح');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainWrapper(),
          ),
        );

      } else {

        String errorMsg =
            userVm.errorMessage ?? 'فشل إنشاء الحساب';

        if (errorMsg.contains('email-already-in-use')) {
          errorMsg =
              _getFirebaseErrorMessage('email-already-in-use');
        }

        else if (errorMsg.contains('weak-password')) {
          errorMsg =
              _getFirebaseErrorMessage('weak-password');
        }

        else if (errorMsg.contains('invalid-email')) {
          errorMsg =
              _getFirebaseErrorMessage('invalid-email');
        }

        _showError(errorMsg);
      }

    } catch (e) {

      String errorMessage = e.toString();

      if (errorMessage.contains('email-already-in-use')) {

        _showError(
          _getFirebaseErrorMessage(
            'email-already-in-use',
          ),
        );

      } else if (errorMessage.contains('weak-password')) {

        _showError(
          _getFirebaseErrorMessage(
            'weak-password',
          ),
        );

      } else if (errorMessage.contains('invalid-email')) {

        _showError(
          _getFirebaseErrorMessage(
            'invalid-email',
          ),
        );

      } else if (errorMessage.contains('network')) {

        _showError(
          _getFirebaseErrorMessage(
            'network-request-failed',
          ),
        );

      } else {

        _showError('حدث خطأ: ${e.toString()}');
      }

    } finally {

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= ERROR =================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  // ================= SUCCESS =================

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}