import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/db_ai.dart';
import 'package:codex_firebase/utils//gemini_service.dart';
import 'base_vm.dart';

class DB_AI_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _gemini = GeminiService();

  Future<List<DBAI>> getAllAIMessages() async {
    try {
      setLoading(true);
      final snapshot = await _firestore
          .collection('ai_messages')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DBAI(
          id: doc.id,
          userId: data['userId'] ?? '',
          prompt: data['prompt'] ?? '',
          response: data['response'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> sendChatToLaravelAndFirebase({
    required String userMessage,
    required String userId,
    required String sanctumToken,
  }) async {
    try {
      setLoading(true);

      // 1 — احفظ رسالة المستخدم فوراً
      await _firestore.collection('ai_chats').add({
        'userId': userId,
        'message': userMessage,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });

      // 2 — اجلب بيانات التطبيق حسب نوع السؤال
      final contextData = await _fetchAppContext(userMessage);

      // 3 — أرسل الرسالة + البيانات
      final enrichedMessage = contextData.isEmpty
          ? userMessage
          : '$userMessage\n\n[بيانات حقيقية من التطبيق — استخدمها في ردك]:$contextData';

      final aiReply = await _gemini.sendMessage(enrichedMessage);

      // 4 — احفظ الرد
      await _firestore.collection('ai_chats').add({
        'userId': userId,
        'message': aiReply,
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

  // ✅ جلب السياق من Firestore
  Future<String> _fetchAppContext(String message) async {
    String context = '';
    final msg = message.toLowerCase();

    final isJob = msg.contains('وظيف') ||
        msg.contains('عمل') ||
        msg.contains('توظيف') ||
        msg.contains('job') ||
        msg.contains('hire') ||
        msg.contains('career');

    final isProduct = msg.contains('منتج') ||
        msg.contains('سعر') ||
        msg.contains('بضاعة') ||
        msg.contains('product') ||
        msg.contains('price') ||
        msg.contains('buy');

    // ✅ وظائف
    if (isJob) {
      try {
        final snap = await _firestore
            .collection('jobs')
            .where('status', isEqualTo: 'open')
            .limit(8)
            .get();

        if (snap.docs.isNotEmpty) {
          context += '\n\nالوظائف المتاحة:\n';
          for (final doc in snap.docs) {
            final d = doc.data();
            context +=
            '• ${d['nameJob'] ?? 'غير محدد'} — الموقع: ${d['location'] ?? 'غير محدد'} — النوع: ${d['jobType'] ?? 'غير محدد'}\n';
          }
        } else {
          context += '\n\nلا توجد وظائف متاحة حالياً.';
        }
      } catch (_) {}
    }

    // ✅ منتجات
    if (isProduct) {
      try {
        final snap = await _firestore
            .collection('products')
            .where('status', isEqualTo: 'available')
            .limit(8)
            .get();

        if (snap.docs.isNotEmpty) {
          context += '\n\nالمنتجات المتاحة:\n';
          for (final doc in snap.docs) {
            final d = doc.data();
            context +=
            '• ${d['name'] ?? 'غير محدد'} — السعر: ${d['price'] ?? 0} — الفئة: ${d['category'] ?? 'عام'}\n';
          }
        } else {
          context += '\n\nلا توجد منتجات متاحة حالياً.';
        }
      } catch (_) {}
    }

    return context;
  }

  // ✅ مسح المحادثة
  Future<void> clearChat(String userId) async {
    try {
      _gemini.clearHistory();
      final docs = await _firestore
          .collection('ai_chats')
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in docs.docs) {
        await doc.reference.delete();
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

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