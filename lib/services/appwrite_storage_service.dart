import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AppwriteStorageService {
  final Client _client;
  late final Storage _storage;

  final String _bucketId = '6a073ce8002fc9dfeaca';
  final String _projectId =
      '6a067722000222d0bfbb'; // تم تغييره للبروجكت الحقيقي

  AppwriteStorageService(this._client) {
    _storage = Storage(_client);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // رفع صورة من File (موبايل / ديسكتوب / ويب)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<models.File> uploadImageFromFile(File imageFile) async {
    late InputFile inputFile;

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      inputFile = InputFile.fromBytes(
        bytes: bytes,
        filename: imageFile.path.split('/').last,
      );
    } else {
      inputFile = InputFile.fromPath(
        path: imageFile.path,
        filename: imageFile.path.split('/').last,
      );
    }

    return await _createFile(inputFile);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // رفع صورة من XFile (image_picker على كل المنصات)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<models.File> uploadImageFromXFile(XFile xFile) async {
    late InputFile inputFile;

    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      inputFile = InputFile.fromBytes(bytes: bytes, filename: xFile.name);
    } else {
      inputFile = InputFile.fromPath(path: xFile.path, filename: xFile.name);
    }

    return await _createFile(inputFile);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // رفع صورة من Bytes مباشرة
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<models.File> uploadImageFromBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final inputFile = InputFile.fromBytes(bytes: bytes, filename: filename);
    return await _createFile(inputFile);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // الدالة الداخلية المشتركة للرفع
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<models.File> _createFile(InputFile inputFile) async {
    try {
      final result = await _storage.createFile(
        bucketId: _bucketId,
        fileId: ID.unique(),
        file: inputFile,
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );
      return result;
    } catch (e) {
      throw Exception('فشل رفع الصورة: $e');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // جلب رابط العرض الكامل
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String getImageUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$_bucketId/files/$fileId/view?project=$_projectId';
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // جلب رابط Preview مع تحديد الأبعاد
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String getImagePreviewUrl(
    String fileId, {
    int width = 400,
    int height = 400,
    int quality = 80,
  }) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$_bucketId/files/$fileId/preview'
        '?width=$width&height=$height&quality=$quality&project=$_projectId';
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // جلب بيانات الصورة كـ Bytes
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<Uint8List?> getImageBytes(String fileId) async {
    try {
      return await _storage.getFileView(bucketId: _bucketId, fileId: fileId);
    } catch (e) {
      print('❌ خطأ في جلب الملف $fileId: $e');
      return null;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // جلب معلومات الملف
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<models.File?> getFileInfo(String fileId) async {
    try {
      return await _storage.getFile(bucketId: _bucketId, fileId: fileId);
    } catch (e) {
      print('❌ خطأ في جلب معلومات الملف: $e');
      return null;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // حذف ملف
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> deleteImage(String fileId) async {
    try {
      await _storage.deleteFile(bucketId: _bucketId, fileId: fileId);
    } catch (e) {
      throw Exception('فشل حذف الصورة: $e');
    }
  }
}
