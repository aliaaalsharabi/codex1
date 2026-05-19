import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _apiKey = 'AIzaSyCS04idEOIu1A8nIYTJb60cQs8YW_rHMEA';
  static const _model = 'gemma-4-31b-it';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  static const _systemPrompt = '''
أنت مساعد ذكي متخصص لتطبيق Codex.
مهمتك الوحيدة هي مساعدة مستخدمي التطبيق في:
- البحث عن وظائف ومنتجات داخل التطبيق
- الإجابة عن أسئلة تخص التطبيق وميزاته
- تقديم نصائح مهنية للباحثين عن عمل
- مساعدة البائعين في وصف منتجاتهم

قواعد صارمة:
- لا تخرج عن نطاق التطبيق أبداً
- إذا سألك المستخدم عن موضوع لا علاقة له بالتطبيق، أجبه بلطف أنك متخصص فقط في مساعدته داخل التطبيق
- تحدث باللغة التي يكتب بها المستخدم (عربي أو إنجليزي)
- كن مختصراً وواضحاً
- لا تذكر أنك Gemini أو Google أو Gemma، أنت مساعد Codex
- لا تعرض تفكيرك أو خطوات تحليلك، اعرض الرد النهائي فقط
''';

  final List<Map<String, dynamic>> _history = [];

  Future<String> sendMessage(String userMessage) async {
    try {
      _history.add({
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ],
      });

      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemPrompt}
          ],
        },
        'contents': _history,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
        },
      });

      final response = await http
          .post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply =
        data['candidates'][0]['content']['parts'][0]['text'] as String;

        // ✅ إزالة التفكير — الموديل يضعه بين <think>...</think>
        reply = _removeThinking(reply);

        _history.add({
          'role': 'model',
          'parts': [
            {'text': reply}
          ],
        });

        return reply.trim();
      } else {
        final error = jsonDecode(response.body);
        final msg = error['error']?['message'] ?? 'خطأ غير معروف';
        return 'خطأ: $msg';
      }
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return 'انتهت مهلة الاتصال، حاول مجدداً.';
      }
      return 'تعذر الاتصال، تأكد من الإنترنت وحاول مجدداً.';
    }
  }

  // ✅ دالة إزالة التفكير
  String _removeThinking(String text) {
    // إزالة <think>...</think>
    text = text.replaceAll(
        RegExp(r'<think>.*?</think>', dotAll: true), '');

    // إزالة <thinking>...</thinking>
    text = text.replaceAll(
        RegExp(r'<thinking>.*?</thinking>', dotAll: true), '');

    // إزالة أسطر التفكير الداخلي
    text = text.replaceAll(
        RegExp(r'\*\s*(Role|Scope|Constraints|Input):.*\n?'), '');

    // إزالة الأسطر الفارغة الزائدة
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  void clearHistory() => _history.clear();
}