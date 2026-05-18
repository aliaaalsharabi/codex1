import 'package:flutter/material.dart';
import 'package:codex_firebase/views/AuthSelection_View.dart';

class OnboardingData {
  final String image, title, description;

  OnboardingData({
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

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'images/1.jpg',
      title: 'مرحباً',
      description: 'يقدم هذا التطبيق استشارات برمجية',
    ),
    OnboardingData(
      image: 'images/2.jpg',
      title: 'وظائف',
      description: 'كما أنه يقدم إعلانات عن وظائف للمبرمجين',
    ),
    OnboardingData(
      image: 'images/3.jpg',
      title: 'متجر تقني',
      description: 'أيضاً يمكن شراء القطع التقنية من التطبيق',
    ),
    OnboardingData(
      image: 'images/4.jpg',
      title: 'ذكاء اصطناعي',
      description: 'ويمكن الاستمتاع بخدمة الذكاء الاصطناعي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFE),
      body: SafeArea(
        child: Column(
          children: [
            // زر التخطي
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AuthSelectionScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      color: Color(0xFF429EBD),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // الصفحات
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // الصورة داخل كارد احترافي
                        Expanded(
                          flex: 6,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEAF7FD),
                                  Colors.white,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF5DB1DF,
                                  ).withOpacity(0.12),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: page.image,
                              child: Image.asset(
                                page.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // العنوان
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF429EBD),
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // الوصف
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                              height: 1.8,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // مؤشرات الصفحات
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                                (dotIndex) {
                              final isActive =
                                  _currentIndex == dotIndex;

                              return AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 300),
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                height: 10,
                                width: isActive ? 30 : 10,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  color: isActive
                                      ? const Color(0xFF5DB1DF)
                                      : Colors.grey.shade300,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 35),

                        // زر التالي
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 6,
                              backgroundColor:
                              const Color(0xFF5DB1DF),
                              shadowColor:
                              const Color(0xFF5DB1DF)
                                  .withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {
                              if (_currentIndex ==
                                  _pages.length - 1) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const AuthSelectionScreen(),
                                  ),
                                );
                              } else {
                                _controller.nextPage(
                                  duration: const Duration(
                                      milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentIndex ==
                                      _pages.length - 1
                                      ? 'ابدأ الآن'
                                      : 'التالي',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}