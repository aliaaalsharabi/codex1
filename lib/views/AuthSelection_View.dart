import 'package:flutter/material.dart';
import 'package:codex_firebase/views/Register_view.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/constants/colors.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color newBrandColor = Color(0xFF5DB1DF);
    const Color darkBlueText = Color(0xFF006699);

    return Scaffold(
      backgroundColor: TColors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            color: newBrandColor,
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'أهلاً بك في منصة\nالمبرمجين',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkBlueText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TColors.white,
                        border: Border.all(color: newBrandColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Image.asset('images/logo.jpg'),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 260,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: newBrandColor.withOpacity(0.7),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        ),
                        child: const Text(
                          'الدخول',
                          style: TextStyle(fontSize: 22, color: darkBlueText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 260,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: newBrandColor.withOpacity(0.7),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'التسجيل',
                          style: TextStyle(fontSize: 22, color: darkBlueText),
                        ),
                      ),
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
}