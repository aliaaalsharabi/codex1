import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/views/AuthSelection_View.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class OnboardingData {
  final String image, title, description;
  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  void _goToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final langVm = context.watch<Language_Vm>();
    final loc = langVm.localization;
    final isRTL = langVm.textDirection == TextDirection.rtl;

    final List<OnboardingData> pages = [
      OnboardingData(image: 'images/1.jpg', title: loc.onboardingTitle1, description: loc.onboardingDesc1),
      OnboardingData(image: 'images/2.jpg', title: loc.onboardingTitle2, description: loc.onboardingDesc2),
      OnboardingData(image: 'images/3.jpg', title: loc.onboardingTitle3, description: loc.onboardingDesc3),
      OnboardingData(image: 'images/4.jpg', title: loc.onboardingTitle4, description: loc.onboardingDesc4),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFE),
      body: SafeArea(
        child: Column(
          children: [

            // ===== TOP BAR — ثابت =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo أو اسم التطبيق
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF429EBD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.layers_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'CODEX',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF429EBD),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // زر التخطي
                  TextButton(
                    onPressed: _goToAuth,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: const Color(0xFF429EBD).withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      loc.skip,
                      style: const TextStyle(
                        color: Color(0xFF429EBD),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== PAGEVIEW — فقط الصورة + النص يتحرك =====
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [

                        // ===== الصورة — فلات بدون كارد =====
                        Expanded(
                          flex: 5,
                          child: Hero(
                            tag: page.image,
                            child: Image.asset(
                              page.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ===== العنوان =====
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2E3B),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ===== الوصف =====
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ===== BOTTOM SECTION — ثابت لا يتحرك =====
            Padding(
              padding: EdgeInsets.fromLTRB(28, 0, 28, size.height * 0.04),
              child: Column(
                children: [

                  // النقاط
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (dotIndex) {
                      final isActive = _currentIndex == dotIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 28 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isActive
                              ? const Color(0xFF429EBD)
                              : const Color(0xFFD0EAF5),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // زر التالي / ابدأ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // ✅ فلات بدون ظل
                        backgroundColor: const Color(0xFF429EBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (_currentIndex == pages.length - 1) {
                          _goToAuth();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isRTL) ...[
                            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            _currentIndex == pages.length - 1 ? loc.getStarted : loc.next,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isRTL) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ],
                      ),
                    ),
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