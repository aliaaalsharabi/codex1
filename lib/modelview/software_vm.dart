import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/software.dart';
import 'base_vm.dart';

class Software_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Software>> getAllSoftware() async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore.collection('software').get();
      List<Software> softwareList = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        softwareList.add(Software(
          id: doc.id,
          userId: data['userId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'],
          version: data['version'],
          downloadUrl: data['downloadUrl'],
          image: data['image'],
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
        ));
      }
      return softwareList;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }
}