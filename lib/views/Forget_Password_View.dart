import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('الرجاء إدخال البريد الإلكتروني', TColors.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage('تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني', TColors.success);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _showMessage(e.toString(), TColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5DB1DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: TSizes.xl),
            const Icon(
              Icons.lock_reset,
              size: 80,
              color: Color(0xFF5DB1DF),
            ),
            const SizedBox(height: TSizes.lg),
            const Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: TSizes.fontSizeLg + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.sm),
            const Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.grey),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'البريد الإلكتروني',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.email, color: Color(0xFF429EBD)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                ),
              ),
            ),
            const SizedBox(height: TSizes.lg),
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
                onPressed: _isLoading ? null : _sendResetEmail,
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
                  'إرسال رابط إعادة التعيين',
                  style: TextStyle(fontSize: TSizes.fontSizeMd, color: TColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}