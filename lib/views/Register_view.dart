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
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'coder';

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى استخدام بريد آخر أو تسجيل الدخول.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح. يرجى إدخال بريد إلكتروني صحيح.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً. يرجى استخدام كلمة مرور أقوى (6 أحرف على الأقل).';
      case 'network-request-failed':
        return 'حدث خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك.';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      body: Stack(
        children: [
          // الخلفية العلوية
          Container(
            height: MediaQuery.of(context).size.height * 0.28,
            decoration: const BoxDecoration(
              color: Color(0xFF5DB1DF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // العنوان
                    const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الكارد الرئيسي
                    Container(
                      padding: const EdgeInsets.all(TSizes.md),
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Consumer<User_Vm>(
                        builder: (context, userVm, child) {
                          return Column(
                            children: [
                              _buildField(
                                  "الاسم", Icons.person, _nameController),
                              const SizedBox(height: 12),

                              _buildField("البريد الإلكتروني", Icons.email,
                                  _emailController),
                              const SizedBox(height: 12),

                              _buildField("رقم الهاتف (اختياري)",
                                  Icons.phone, _phoneController),
                              const SizedBox(height: 12),

                              _buildDropdown(),
                              const SizedBox(height: 12),

                              _buildPasswordField(
                                "كلمة المرور",
                                _passwordController,
                                _obscurePassword,
                                    () => setState(() =>
                                _obscurePassword = !_obscurePassword),
                              ),
                              const SizedBox(height: 12),

                              _buildPasswordField(
                                "تأكيد كلمة المرور",
                                _confirmPasswordController,
                                _obscureConfirmPassword,
                                    () => setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword),
                              ),

                              const SizedBox(height: 25),

                              SizedBox(
                                height: 55,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5DB1DF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleRegister(userVm),
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Text(
                                    "تسجيل",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "تسجيل الدخول",
                                      style: TextStyle(
                                        color: Color(0xFF429EBD),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Text("لديك حساب؟"),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // زر الرجوع
          Positioned(
            top: 50,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF5DB1DF)),
        filled: true,
        fillColor: const Color(0xFFF0F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
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
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF5DB1DF)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF0F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUserType,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'coder', child: Text('مبرمج')),
            DropdownMenuItem(value: 'company', child: Text('شركة')),
            DropdownMenuItem(value: 'vendor', child: Text('بائع')),
            DropdownMenuItem(value: 'consultant', child: Text('مستشار')),
          ],
          onChanged: (value) =>
              setState(() => _selectedUserType = value!),
        ),
      ),
    );
  }

  Future<void> _handleRegister(User_Vm userVm) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("كلمة المرور غير متطابقة")),
      );
      return;
    }

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainWrapper()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}