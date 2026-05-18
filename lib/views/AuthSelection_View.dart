import 'package:flutter/material.dart';
import 'package:codex_firebase/views/Register_view.dart';
import 'package:codex_firebase/views/Login_View.dart';
import 'package:codex_firebase/constants/colors.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF5DB1DF);
    const Color darkBlueText = Color(0xFF0F4C75);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      body: Stack(
        children: [

          // ================= TOP BACKGROUND =================

          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            width: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5DB1DF),
                  Color(0xFF7BCBF4),
                ],

                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
          ),

          // ================= DECORATION CIRCLES =================

          Positioned(
            top: -50,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          Positioned(
            top: 80,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // ================= MAIN CONTENT =================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(35),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      // ================= LOGO =================

                      Container(
                        width: 170,
                        height: 170,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,

                          border: Border.all(
                            color: primaryBlue.withOpacity(0.25),
                            width: 3,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: ClipOval(
                            child: Image.asset(
                              'images/logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ================= TITLE =================

                      const Text(
                        'أهلاً بك في منصة المبرمجين',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: darkBlueText,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'ابدأ رحلتك البرمجية واستكشف الوظائف\nوالمنتجات والاستشارات التقنية',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.8,
                        ),
                      ),

                      const SizedBox(height: 45),

                      // ================= LOGIN BUTTON =================

                      SizedBox(
                        width: double.infinity,
                        height: 58,

                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const LoginScreen(),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primaryBlue,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),

                            shadowColor:
                            primaryBlue.withOpacity(0.4),
                          ),

                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                                size: 24,
                              ),

                              SizedBox(width: 10),

                              Text(
                                'الدخول',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ================= REGISTER BUTTON =================

                      SizedBox(
                        width: double.infinity,
                        height: 58,

                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const RegisterScreen(),
                              ),
                            );
                          },

                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: primaryBlue.withOpacity(0.4),
                              width: 2,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),

                            backgroundColor:
                            primaryBlue.withOpacity(0.05),
                          ),

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.person_add_alt_1_rounded,
                                color: primaryBlue,
                                size: 24,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                'التسجيل',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ================= FOOTER =================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Container(
                            width: 35,
                            height: 2,
                            color: Colors.grey.shade300,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),

                            child: Text(
                              'Codex Platform',

                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Container(
                            width: 35,
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}