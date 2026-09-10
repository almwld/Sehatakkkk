// ============================================================
// 📁 lib/core/services/image_kit_service.dart
// 🖼️ خدمة ImageKit لإدارة الصور
// ============================================================

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sehatak/core/config/imagekit_config.dart';

class ImageKitService {
  static final ImageKitService _instance = ImageKitService._internal();
  factory ImageKitService() => _instance;
  ImageKitService._internal();

  static const String _baseUrl = ImageKitConfig.baseUrl;
  static const String _apiKey = 'YOUR_IMAGEKIT_API_KEY';
  static const String _privateKey = 'YOUR_IMAGEKIT_PRIVATE_KEY';

  Future<String> uploadImage({
    required File file,
    required String folder,
    String? fileName,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final url = '$_baseUrl/v1/files/upload';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}';
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName ?? file.path.split('/').last));
      request.fields['folder'] = folder;
      if (customMetadata != null) request.fields['customMetadata'] = jsonEncode(customMetadata);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = jsonDecode(responseData);
      if (response.statusCode == 200) return result['url'] as String;
      throw Exception('Upload failed: ${result['message']}');
    } catch (e) {
      print('Image upload error: $e');
      rethrow;
    }
  }

  Future<String> uploadImageFromUrl({required String imageUrl, required String folder, String? fileName}) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) throw Exception('Failed to download image from URL');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${fileName ?? DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(response.bodyBytes);
      return await uploadImage(file: tempFile, folder: folder, fileName: fileName);
    } catch (e) {
      print('Upload from URL error: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String fileId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/v1/files/$fileId'),
        headers: {'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}'},
      );
      if (response.statusCode != 204) throw Exception('Delete failed: ${response.body}');
    } catch (e) {
      print('Image delete error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listImages({String? folder, int limit = 20, int page = 1}) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/files').replace(queryParameters: {
        if (folder != null) 'folder': folder,
        'limit': limit.toString(),
        'page': page.toString(),
      });
      final response = await http.get(url, headers: {'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}'});
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      throw Exception('List failed: ${response.body}');
    } catch (e) {
      print('List images error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/files/search').replace(queryParameters: {'q': query});
      final response = await http.get(url, headers: {'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}'});
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      throw Exception('Search failed: ${response.body}');
    } catch (e) {
      print('Search images error: $e');
      rethrow;
    }
  }

  static String getImageUrl({required String path, int? width, int? height, bool crop = false, int quality = 80, String format = 'auto'}) {
    String url = '$_baseUrl$path';
    final params = <String>[];
    if (width != null) params.add('w-$width');
    if (height != null) params.add('h-$height');
    if (crop) params.add('c-main');
    params.add('q-$quality');
    params.add('f-$format');
    if (params.isNotEmpty) url += '?tr=${params.join(',')}';
    return url;
  }

  static Future<String> imageToBase64(File imageFile) async {
    try {
      return base64Encode(await imageFile.readAsBytes());
    } catch (e) {
      print('Image to base64 error: $e');
      return '';
    }
  }

  static Future<File?> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Download failed');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      print('Download image error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/v1/files/statistics'), headers: {'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}'});
      if (response.statusCode == 200) return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      throw Exception('Statistics failed: ${response.body}');
    } catch (e) {
      print('Statistics error: $e');
      return {};
    }
  }
}
