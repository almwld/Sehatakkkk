import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String> getAppDirectory() async => (await getApplicationDocumentsDirectory()).path;
  static Future<String> getCacheDirectory() async => (await getTemporaryDirectory()).path;
  static Future<String> getChatDirectory(String chatId) async { final dir = Directory(path.join(await getAppDirectory(), 'chats', chatId)); if (!await dir.exists()) await dir.create(recursive: true); return dir.path; }
  static Future<String> getImagesDirectory(String chatId) async { final dir=Directory(path.join(await getChatDirectory(chatId),'images')); if(!await dir.exists()) await dir.create(recursive:true); return dir.path; }
  static Future<String> getAudioDirectory(String chatId) async { final dir=Directory(path.join(await getChatDirectory(chatId),'audio')); if(!await dir.exists()) await dir.create(recursive:true); return dir.path; }
  static Future<String> getFilesDirectory(String chatId) async { final dir=Directory(path.join(await getChatDirectory(chatId),'files')); if(!await dir.exists()) await dir.create(recursive:true); return dir.path; }
  static Future<bool> fileExists(String filePath) async => File(filePath).exists();
  static Future<String> readFile(String filePath) async { final file=File(filePath); return await file.exists()?file.readAsString():''; }
  static Future<void> writeFile(String filePath,String content) => File(filePath).writeAsString(content);
  static Future<void> deleteFile(String filePath) async { final file=File(filePath); if(await file.exists()) await file.delete(); }
  static Future<void> copyFile(String source,String destination) async { final file=File(source); if(await file.exists()) await file.copy(destination); }
  static Future<void> moveFile(String source,String destination) async { final file=File(source); if(await file.exists()) await file.rename(destination); }
  static Future<int> getFileSize(String filePath) async { final file=File(filePath); return await file.exists()?file.length():0; }
  static String formatFileSize(int bytes){if(bytes<1024)return '$bytes B';if(bytes<1024*1024)return '${(bytes/1024).toStringAsFixed(1)} KB';if(bytes<1024*1024*1024)return '${(bytes/(1024*1024)).toStringAsFixed(1)} MB';return '${(bytes/(1024*1024*1024)).toStringAsFixed(1)} GB';}
  static String getFileExtension(String fileName){final parts=fileName.split('.');return parts.length<2?'':parts.last.toLowerCase();}
  static String getMimeType(String fileName){switch(getFileExtension(fileName)){case 'jpg':case 'jpeg':return 'image/jpeg';case 'png':return 'image/png';case 'gif':return 'image/gif';case 'webp':return 'image/webp';case 'mp4':return 'video/mp4';case 'mov':return 'video/quicktime';case 'avi':return 'video/x-msvideo';case 'mkv':return 'video/x-matroska';case 'mp3':return 'audio/mpeg';case 'wav':return 'audio/wav';case 'm4a':return 'audio/mp4';case 'pdf':return 'application/pdf';case 'doc':return 'application/msword';case 'docx':return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';case 'xls':return 'application/vnd.ms-excel';case 'xlsx':return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';case 'ppt':return 'application/vnd.ms-powerpoint';case 'pptx':return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';case 'txt':return 'text/plain';case 'zip':return 'application/zip';case 'rar':return 'application/x-rar-compressed';case '7z':return 'application/x-7z-compressed';default:return 'application/octet-stream';}}
  static Future<void> deleteDirectory(String dirPath) async {final dir=Directory(dirPath);if(await dir.exists())await dir.delete(recursive:true);}
  static Future<void> clearDirectory(String dirPath) async {final dir=Directory(dirPath);if(!await dir.exists())return;for(final entity in await dir.list().toList()){if(entity is File)await entity.delete();else if(entity is Directory)await entity.delete(recursive:true);}}
  static Future<List<FileSystemEntity>> listFiles(String dirPath) async {final dir=Directory(dirPath);return await dir.exists()?dir.list().toList():[];}
  static Future<List<File>> listFilesByExtension(String dirPath,String extension) async {final files=<File>[];for(final entity in await listFiles(dirPath)){if(entity is File&&getFileExtension(entity.path)==extension)files.add(entity);}return files;}
  static String generateUniqueFileName(String prefix,String extension){final timestamp=DateTime.now().millisecondsSinceEpoch;return '${prefix}_$timestamp.$extension';}
  static String generateUniqueFileNameWithId(String prefix,String extension,String id){final timestamp=DateTime.now().millisecondsSinceEpoch;return '${prefix}_${id}_$timestamp.$extension';}
}
