import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/report.dart';
import 'base_vm.dart';

class Report_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReport(Report report) async {
    try {
      setLoading(true);
      await _firestore.collection('reports').doc(report.id).set({
        'userId': report.userId,
        'reportedUserId': report.reportedUserId,
        'reason': report.reason,
        'status': report.status,
        'createdAt': Timestamp.fromDate(report.createdAt),
      });
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}