import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/reserve.dart';
import 'base_vm.dart';

class Reserve_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReservation(Reserve reserve) async {
    try {
      setLoading(true);
      await _firestore.collection('reservations').doc(reserve.id).set({
        'userId': reserve.userId,
        'consultationId': reserve.consultationId,
        'reserveDate': Timestamp.fromDate(reserve.reserveDate),
        'status': reserve.status,
        'createdAt': Timestamp.fromDate(reserve.createdAt),
      });
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}