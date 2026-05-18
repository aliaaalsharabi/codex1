import 'package:flutter/material.dart';
import 'package:codex_firebase/views/Onboarding_view.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Fade Animation
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Scale Animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Slide Animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // الانتقال بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, animation, __) =>
            const OnboardingScreen(),
            transitionsBuilder:
                (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // خلفية احترافية متدرجة
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5DB1DF),
              Color(0xFF429EBD),
              Color(0xFF1E6D97),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Stack(
          children: [
            // دوائر زخرفية بالخلفية
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -100,
              right: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // المحتوى الرئيسي
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        // اللوجو
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.18),
                                  blurRadius: 35,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.all(20),
                              child: ClipOval(
                                child: Image.asset(
                                  'images/logo.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 45),

                        // اسم التطبيق
                        const Text(
                          'CODEX',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // خط زخرفي
                        Container(
                          width: 90,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // Welcome Text
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 35),
                          child: Text(
                            'To Programmers World',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.white
                                  .withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 55),

                        // Loading Indicator
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}