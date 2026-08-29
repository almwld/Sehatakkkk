// ============================================================
// 📁 مساعد الملفات
// ============================================================

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  // ============================================================
  // 📁 الحصول على المسارات
  // ============================================================

  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<String> getChatDirectory(String chatId) async {
    final appDir = await getAppDirectory();
    final chatDir = path.join(appDir, 'chats', chatId);
    final dir = Directory(chatDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return chatDir;
  }

  static Future<String> getImagesDirectory(String chatId) async {
    final chatDir = await getChatDirectory(chatId);
    final imagesDir = path.join(chatDir, 'images');
    final dir = Directory(imagesDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return imagesDir;
  }

  static Future<String> getAudioDirectory(String chatId) async {
    final chatDir = await getChatDirectory(chatId);
    final audioDir = path.join(chatDir, 'audio');
    final dir = Directory(audioDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return audioDir;
  }

  static Future<String> getFilesDirectory(String chatId) async {
    final chatDir = await getChatDirectory(chatId);
    final filesDir = path.join(chatDir, 'files');
    final dir = Directory(filesDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return filesDir;
  }

  // ============================================================
  // 📝 عمليات الملفات
  // ============================================================

  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return '';
    return await file.readAsString();
  }

  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> copyFile(String source, String destination) async {
    final sourceFile = File(source);
    if (!await sourceFile.exists()) return;
    await sourceFile.copy(destination);
  }

  static Future<void> moveFile(String source, String destination) async {
    final sourceFile = File(source);
    if (!await sourceFile.exists()) return;
    await sourceFile.rename(destination);
  }

  // ============================================================
  // 📊 معلومات الملف
  // ============================================================

  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }

  static String getMimeType(String fileName) {
    final ext = getFileExtension(fileName);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      default:
        return 'application/octet-stream';
    }
  }

  // ============================================================
  // 🗑️ حذف المجلدات
  // ============================================================

  static Future<void> deleteDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<void> clearDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;
    final files = await dir.list().toList();
    for (final file in files) {
      if (file is File) {
        await file.delete();
      } else if (file is Directory) {
        await file.delete(recursive: true);
      }
    }
  }

  // ============================================================
  // 📋 قائمة الملفات
  // ============================================================

  static Future<List<FileSystemEntity>> listFiles(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];
    return await dir.list().toList();
  }

  static Future<List<File>> listFilesByExtension(String dirPath, String extension) async {
    final entities = await listFiles(dirPath);
    final files = <File>[];
    for (final entity in entities) {
      if (entity is File) {
        final ext = getFileExtension(entity.path);
        if (ext == extension) {
          files.add(entity);
        }
      }
    }
    return files;
  }

  // ============================================================
  // 📝 إنشاء اسم فريد
  // ============================================================

  static String generateUniqueFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix_$timestamp.$extension';
  }

  static String generateUniqueFileNameWithId(String prefix, String extension, String id) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix_${id}_$timestamp.$extension';
  }
}
