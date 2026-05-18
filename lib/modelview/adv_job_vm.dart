import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/advertisement_job.dart';
import 'base_vm.dart';

class Advertisement_of_jop_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AdvertisementJob>> getAllJobs() async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore.collection('jobs').get();
      List<AdvertisementJob> jobs = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        jobs.add(AdvertisementJob(
          idJob: doc.id,
          userId: data['userId'] ?? '',
          numberOfLike: data['numberOfLike'],
          commentId: data['commentId'],
          nameJob: data['nameJob'] ?? '',
          description: data['description'],
          imageId: data['image'],
          location: data['location'],
          jobType: data['jobType'],
          status: data['status'] ?? 'open',
          deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
          updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
        ));
      }
      return jobs;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }
}