import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/db_ai.dart';
import 'base_vm.dart';

class DB_AI_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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