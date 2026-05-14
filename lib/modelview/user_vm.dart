import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'base_vm.dart';

// تعريف بسيط لكلاس User داخل نفس الملف لتجنب أي تعارض
class SimpleUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String userType;
  final DateTime createdAt;

  SimpleUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.userType,
    required this.createdAt,
  });
}

class User_Vm extends BaseVM {
  SimpleUser? _currentUser;
  SimpleUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ دالة تسجيل الدخول مع تحسين معالجة الأخطاء
  Future<SimpleUser?> login(String email, String password) async {
    try {
      setLoading(true);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _getUser(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      // ✅ تمرير رمز الخطأ بدلاً من الرسالة الإنجليزية
      String errorKey = e.code;
      setError(errorKey); // سنقوم بترجمة الخطأ في الواجهة
      return null;
    } catch (e) {
      setError('network-request-failed');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة التسجيل مع تحسين معالجة الأخطاء
  Future<SimpleUser?> register(Map<String, dynamic> userData) async {
    try {
      setLoading(true);
      String email = userData['email'].trim();
      String password = userData['password'];

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      SimpleUser newUser = SimpleUser(
        uid: uid,
        name: userData['name'] ?? '',
        email: email,
        phone: userData['phone'],
        userType: userData['user_type'] ?? 'coder',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set({
        'name': newUser.name,
        'email': newUser.email,
        'phone': newUser.phone,
        'userType': newUser.userType,
        'createdAt': Timestamp.fromDate(newUser.createdAt),
      });

      _currentUser = newUser;
      notifyListeners();
      return newUser;
    } on FirebaseAuthException catch (e) {
      // ✅ تمرير رمز الخطأ بدلاً من الرسالة الإنجليزية
      setError(e.code);
      return null;
    } catch (e) {
      setError('network-request-failed');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ✅ دالة جلب المستخدم الحالي
  Future<SimpleUser?> fetchCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUser(firebaseUser.uid);
  }

  // ✅ دالة التحقق من حالة تسجيل الدخول
  Future<bool> checkLoginStatus() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await fetchCurrentUser();
      return _currentUser != null;
    }
    return false;
  }

  // ✅ دالة جلب جميع المستخدمين
  Future<List<SimpleUser>> getAllUser() async {
    try {
      setLoading(true);
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<SimpleUser> users = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        users.add(SimpleUser(
          uid: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          userType: data['userType'] ?? 'coder',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        ));
      }
      return users;
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة جلب مستخدم بواسطة ID
  Future<SimpleUser?> _getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      var data = doc.data() as Map<String, dynamic>;
      SimpleUser user = SimpleUser(
        uid: uid,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'],
        userType: data['userType'] ?? 'coder',
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      return null;
    }
  }

  // ✅ دالة تحديث المستخدم
  Future<Map<String, dynamic>?> updateUser(Map<String, dynamic> updates) async {
    try {
      setLoading(true);
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        setError('المستخدم غير مسجل الدخول');
        return null;
      }

      await _firestore.collection('users').doc(userId).update(updates);

      // جلب البيانات المحدثة
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data() as Map<String, dynamic>;

      // تحديث الكائن المحلي
      _currentUser = SimpleUser(
        uid: userId,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'],
        userType: data['userType'] ?? 'coder',
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
      notifyListeners();

      return data;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    try {
      setLoading(true);
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      setError(e.code);
      return false;
    } catch (e) {
      setError('network-request-failed');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة تغيير كلمة المرور
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) {
        setError('user-not-found');
        return false;
      }

      // إعادة المصادقة قبل تغيير كلمة المرور
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      setError(e.code);
      return false;
    } catch (e) {
      setError('network-request-failed');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة تحديث البريد الإلكتروني
  Future<bool> updateEmail(String newEmail) async {
    try {
      setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) {
        setError('user-not-found');
        return false;
      }
      await user.updateEmail(newEmail.trim());

      // تحديث البريد في Firestore أيضاً
      if (_currentUser != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail.trim(),
        });
        _currentUser = SimpleUser(
          uid: _currentUser!.uid,
          name: _currentUser!.name,
          email: newEmail.trim(),
          phone: _currentUser!.phone,
          userType: _currentUser!.userType,
          createdAt: _currentUser!.createdAt,
        );
        notifyListeners();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      setError(e.code);
      return false;
    } catch (e) {
      setError('network-request-failed');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ دالة حذف الحساب
  Future<bool> deleteAccount() async {
    try {
      setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) {
        setError('user-not-found');
        return false;
      }

      // حذف بيانات المستخدم من Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // حذف الحساب من Authentication
      await user.delete();

      _currentUser = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      setError(e.code);
      return false;
    } catch (e) {
      setError('network-request-failed');
      return false;
    } finally {
      setLoading(false);
    }
  }
}