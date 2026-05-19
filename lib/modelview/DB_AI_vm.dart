import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/db_ai.dart';
import 'package:codex_firebase/services/ai_service.dart'; // استيراد السيرفيس الجديد
import 'base_vm.dart';

class DB_AI_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService = AIService(); // دمج السيرفيس داخل الـ ViewModel

  Future<List<DBAI>> getAllAIMessages() async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore
          .collection('ai_messages')
          .orderBy('createdAt', descending: true)
          .get();
      List<DBAI> messages = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        messages.add(DBAI(
          id: doc.id,
          userId: data['userId'] ?? '',
          prompt: data['prompt'] ?? '',
          response: data['response'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        ));
      }
      return messages;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// دالة معالجة إرسال الرسالة وجلب الرد الفعلي من اللارفيل وحفظه بالفايربيس
  Future<bool> sendChatToLaravelAndFirebase({
    required String userMessage,
    required String userId,
    required String sanctumToken,
  }) async {
    try {
      setLoading(true);

      // 1. حفظ رسالة المستخدم في مجموعة 'ai_chats' بالفايربيس لعرضها فوراً
      await _firestore.collection('ai_chats').add({
        'userId': userId,
        'message': userMessage,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });

      // 2. إرسال الطلب للارفيل ليعود برد الذكاء الاصطناعي الحقيقي من Groq
      String? realAIResponse = await _aiService.getSmartChatResponse(
        message: userMessage,
        sanctumToken: sanctumToken,
      );

      // رد احتياطي محلي داخل الفلاتر إذا تعطل السيرفر فجأة
      if (realAIResponse == null || realAIResponse.isEmpty) {
        realAIResponse = "عذراً، لم أتمكن من الاتصال بالخادم الرئيسي حالياً. يرجى مراجعة الاتصال.";
      }

      // 3. حفظ رد الـ AI الفعلي القادم من اللارفيل داخل الفايربيس ليتحدث الـ StreamBuilder تلقائياً
      await _firestore.collection('ai_chats').add({
        'userId': userId,
        'message': realAIResponse,
        'isUser': false,
        'timestamp': Timestamp.now(),
      });

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // الدالة القديمة نتركها كما هي للاحتياط
  Future<void> addAIMessage(DBAI message) async {
    try {
      setLoading(true);
      await _firestore.collection('ai_messages').doc(message.id).set({
        'userId': message.userId,
        'prompt': message.prompt,
        'response': message.response,
        'createdAt': Timestamp.fromDate(message.createdAt),
      });
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}