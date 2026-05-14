import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codex_firebase/model/permission.dart';
import 'base_vm.dart';

class Permission_Vm extends BaseVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Permission>> getAllPermissions() async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore.collection('permissions').get();
      List<Permission> permissions = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        permissions.add(Permission(
          id: doc.id,
          userId: data['userId'] ?? '',
          permissionType: data['permissionType'] ?? 'user',
          isActive: data['isActive'] ?? true,
          grantedAt: (data['grantedAt'] as Timestamp).toDate(),
          expiresAt: data['expiresAt'] != null
              ? (data['expiresAt'] as Timestamp).toDate()
              : null,
        ));
      }
      return permissions;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> addPermission(Permission permission) async {
    try {
      setLoading(true);
      await _firestore.collection('permissions').doc(permission.id).set({
        'userId': permission.userId,
        'permissionType': permission.permissionType,
        'isActive': permission.isActive,
        'grantedAt': Timestamp.fromDate(permission.grantedAt),
        'expiresAt': permission.expiresAt != null
            ? Timestamp.fromDate(permission.expiresAt!)
            : null,
      });
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}