import 'package:codex_firebase/views/New_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart'; // ✅ دعم الثيم
import 'package:codex_firebase/views/chat_screen.dart';
import 'package:codex_firebase/views/Ai_chat_Screen.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ConsultationsScreen extends StatelessWidget {
  const ConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة الثيم
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final primaryBlue = const Color(0xFF5DB1DF);
    final cardColor = isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,

      // إزالة الـ AppBar والـ BottomNavigationBar بناءً على طلبك

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: ListView(
              children: [
                const SizedBox(height: 10),
                // 1. استشارات Flutter
                _buildConsultationCard(
                  context,
                  isDark: isDark,
                  cardColor: cardColor,
                  title: 'استشارات Flutter',
                  subtitle: 'استشارات متخصصة في تطوير تطبيقات Flutter',
                  date: '5/5/2026',
                  status: 'متصل',
                  statusColor: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
                ),
                const SizedBox(height: TSizes.md),

                // 2. استشارات Laravel
                _buildConsultationCard(
                  context,
                  isDark: isDark,
                  cardColor: cardColor,
                  title: 'استشارات Laravel',
                  subtitle: 'تطوير واجهات خلفية باستخدام Laravel',
                  date: '5/5/2026',
                  status: 'متصل',
                  statusColor: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
                ),
                const SizedBox(height: TSizes.md),

                // 3. استشارات الذكاء الاصطناعي
                _buildConsultationCard(
                  context,
                  isDark: isDark,
                  cardColor: cardColor,
                  title: 'استشارات الذكاء الاصطناعي',
                  subtitle: 'حلول الذكاء الاصطناعي وتعلم الآلة',
                  date: '5/5/2026',
                  status: 'غير متصل',
                  statusColor: Colors.grey,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatScreen())),
                ),
              ],
            ),
          ),

          // زر القلم العائم لفتح محادثة جديدة (كما في الصورة)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'new_chat_fab',
              backgroundColor: isDark ? TColors.darkerGrey : TColors.white,
              onPressed: () {
                // منطق فتح محادثة جديدة
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewMessageScreen()));
              },
              child: Icon(Icons.edit, color: primaryBlue),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(
      BuildContext context, {
        required bool isDark,
        required Color cardColor,
        required String title,
        required String subtitle,
        required String date,
        required String status,
        required Color statusColor,
        required VoidCallback onTap,
      }) {
    final primaryBlue = const Color(0xFF5DB1DF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // التاريخ على اليسار
            Text(date, style: TextStyle(color: TColors.grey, fontSize: 12)),

            const SizedBox(width: 10),

            // المحتوى في المنتصف (نص محاذى لليمين)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? TColors.white : TColors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: primaryBlue, fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(status, style: TextStyle(color: TColors.grey, fontSize: 11)),
                      const SizedBox(width: 5),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),

            // الأيقونة على اليمين
            Icon(Icons.chat_bubble_rounded, color: Colors.grey.shade400, size: 30),
          ],
        ),
      ),
    );
  }
}