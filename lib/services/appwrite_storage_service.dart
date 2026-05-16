import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';

class AppwriteStorageService {
  final Client _client;
  late final Storage _storage;
  final String _bucketId = '6a073ce8002fc9dfeaca'; // ✅ اسم الحاوية الخاصة بك

  AppwriteStorageService(this._client) {
    _storage = Storage(_client);
  }

  // ✅ دالة رفع ملف مع تحسين معالجة MIME type
  Future<models.File> uploadImage(File imageFile) async {
    // تحديد نوع الملف بشكل آمن
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    final inputFile = InputFile.fromPath(
      path: imageFile.path,
      filename: imageFile.path.split('/').last,
    );

    try {
      final result = await _storage.createFile(
        bucketId: _bucketId,
        fileId: ID.unique(),
        file: inputFile,
      );
      return result;
    } catch (e) {
      throw Exception('فشل رفع الصورة: $e');
    }
  }

  // ✅ دالة جلب رابط العرض (الأسهل والأسرع)
  String getImageUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$_bucketId/files/$fileId/view';
  }

  // ✅ دالة جلب رابط مع إعدادات (مثال: تصغير الحجم)
  String getImagePreviewUrl(String fileId, {int width = 200, int height = 200}) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$_bucketId/files/$fileId/preview?width=$width&height=$height';
  }

  // ✅ دالة حذف ملف
  Future<void> deleteImage(String fileId) async {
    try {
      await _storage.deleteFile(bucketId: _bucketId, fileId: fileId);
    } catch (e) {
      throw Exception('فشل حذف الصورة: $e');
    }
  }

  // ✅ دالة جلب بيانات الملف (مع معالجة أفضل للأخطاء)
  Future<Uint8List?> getImageBytes(String fileId) async {
    try {
      final bytes = await _storage.getFileView(
        bucketId: _bucketId,
        fileId: fileId,
      );
      return bytes;
    } catch (e) {
      print('❌ خطأ في جلب الملف $fileId: $e');
      return null;
    }
  }

  // ✅ دالة جلب معلومات الملف
  Future<models.File?> getFileInfo(String fileId) async {
    try {
      return await _storage.getFile(
        bucketId: _bucketId,
        fileId: fileId,
      );
    } catch (e) {
      print('❌ خطأ في جلب معلومات الملف: $e');
      return null;
    }
  }
}