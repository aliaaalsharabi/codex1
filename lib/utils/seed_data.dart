import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleJobs() async {
    try {
      // بيانات تجريبية للوظائف
      final sampleJobs = [
        {
          'nameJob': 'مطور Flutter',
          'description': 'نبحث عن مطور Flutter ذو خبرة لتطوير تطبيقات متعددة المنصات',
          'location': 'الرياض، السعودية',
          'jobType': 'دوام كامل',
          'status': 'open',
          'numberOfLike': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'nameJob': 'مصمم UI/UX',
          'description': 'مطلوب مصمم واجهات مستخدم لتصميم تطبيقات الجوال',
          'location': 'جدة، السعودية',
          'jobType': 'عن بعد',
          'status': 'open',
          'numberOfLike': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'nameJob': 'مطور Backend Laravel',
          'description': 'مطلوب مطور خلفيات بخبرة في Laravel',
          'location': 'الدمام، السعودية',
          'jobType': 'دوام كامل',
          'status': 'open',
          'numberOfLike': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (var job in sampleJobs) {
        await _firestore.collection('jobs').add(job);
      }
      print('تمت إضافة البيانات التجريبية بنجاح');
    } catch (e) {
      print('خطأ في إضافة البيانات: $e');
    }
  }

  Future<void> addSampleProducts() async {
    try {
      final sampleProducts = [
        {
          'name': 'لابتوب Dell XPS',
          'price': 4500,
          'description': 'لابتوب عالي الأداء للمبرمجين',
          'category': 'electronics',
          'status': 'available',
          'stockQuantity': 5,
          'createdAt': Timestamp.now(),
        },
        {
          'name': 'ماوس لاسلكي',
          'price': 150,
          'description': 'ماوس احترافي للمبرمجين',
          'category': 'accessories',
          'status': 'available',
          'stockQuantity': 20,
          'createdAt': Timestamp.now(),
        },
        {
          'name': 'شاشة 27 بوصة',
          'price': 1200,
          'description': 'شاشة 4K مثالية للمبرمجين',
          'category': 'electronics',
          'status': 'available',
          'stockQuantity': 8,
          'createdAt': Timestamp.now(),
        },
      ];

      for (var product in sampleProducts) {
        await _firestore.collection('products').add(product);
      }
      print('تمت إضافة المنتجات التجريبية بنجاح');
    } catch (e) {
      print('خطأ في إضافة المنتجات: $e');
    }
  }
}