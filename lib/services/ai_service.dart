import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // استخدام IP المحاكي الافتراضي
  final String baseUrl = "http://10.0.2.2:8000/api";

  /// إرسال الرسالة إلى دالة smartChat في اللارفيل للاتصال بـ Groq
  Future<String?> getSmartChatResponse({
    required String message,
    required String sanctumToken,
  }) async {
    try {
      // 🟢 التعديل: إضافة /ai/ ليصبح المسار مطابقاً تماماً للارفيل
      final url = Uri.parse('$baseUrl/ai/smart-chat');

      print("🌐 جاري إرسال الطلب إلى السيرفر: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // تم إيقاف الهيدر مؤقتاً لأننا جعلنا المسار عاماً في لارفيل للاختبار
          // 'Authorization': 'Bearer $sanctumToken',
        },
        body: jsonEncode({
          'message': message,
        }),
      ).timeout(const Duration(seconds: 15));

      print("📊 كود استجابة السيرفر: ${response.statusCode}");
      print("📄 جسم الاستجابة (Body): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // قراءة مرنة للرد الراجع من الكنترولر
        if (responseData.containsKey('data') && responseData['data'] is Map && responseData['data'].containsKey('ai_response')) {
          return responseData['data']['ai_response'].toString();
        } else if (responseData.containsKey('response')) {
          return responseData['response'].toString();
        } else if (responseData.containsKey('message')) {
          return responseData['message'].toString();
        } else if (responseData.containsKey('reply')) {
          return responseData['reply'].toString();
        }

        return response.body;
      }
      return null;
    } catch (e) {
      print("❌ خطأ حرج أثناء الاتصال بـ Laravel AI: $e");
      return null;
    }
  }
}