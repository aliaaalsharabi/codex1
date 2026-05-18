import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'الرجاء إدخال البريد الإلكتروني',
        TColors.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      _showMessage(
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        TColors.success,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _showMessage(
        e.toString(),
        TColors.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF5DB1DF);
    const Color darkBlue = Color(0xFF006699);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFE),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [

              /// زر الرجوع
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: darkBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// أيقونة
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withOpacity(0.9),
                      const Color(0xFF429EBD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.35),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 65,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 35),

              /// العنوان
              const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),

              const SizedBox(height: 14),

              /// الوصف
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.7,
                  ),
                ),
              ),

              const SizedBox(height: 45),

              /// الكارد الرئيسي
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
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

                    /// حقل البريد
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),

                      decoration: InputDecoration(
                        hintText: 'البريد الإلكتروني',
                        hintTextDirection: TextDirection.rtl,

                        filled: true,
                        fillColor: const Color(0xFFF4F8FB),

                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: primaryBlue,
                          ),
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
                            color: primaryBlue,
                            width: 1.5,
                          ),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// زر الإرسال
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        onPressed:
                        _isLoading ? null : _sendResetEmail,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                        ),

                        child: _isLoading
                            ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'إرسال رابط إعادة التعيين',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              /// ملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: primaryBlue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تأكد من إدخال البريد الإلكتروني المرتبط بحسابك ليتم إرسال رابط إعادة التعيين بنجاح.',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}