import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sehatak/core/config/imagekit_config.dart';

/// ImageKit public delivery helpers.
///
/// ImageKit private/admin credentials must never be shipped inside the APK.
/// Uploads and administrative operations belong to a trusted backend. Chat
/// media already uses Nextcloud, so this service remains focused on delivery
/// and safe client-side transformations.
class ImageKitService {
  static final ImageKitService _instance = ImageKitService._internal();
  factory ImageKitService() => _instance;
  ImageKitService._internal();

  static const String _baseUrl = ImageKitConfig.baseUrl;

  Future<String> uploadImage({required File file, required String folder, String? fileName, Map<String, String>? customMetadata}) async {
    throw StateError('ImageKit upload requires server-generated authentication; use the trusted backend.');
  }

  Future<String> uploadImageFromUrl({required String imageUrl, required String folder, String? fileName}) async {
    throw StateError('ImageKit upload requires server-generated authentication; use the trusted backend.');
  }

  Future<void> deleteImage(String fileId) async {
    throw StateError('ImageKit delete is an admin operation and must run on the trusted backend.');
  }

  Future<List<Map<String, dynamic>>> listImages({String? folder, int limit = 20, int page = 1}) async {
    throw StateError('ImageKit file listing is an admin operation and must run on the trusted backend.');
  }

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    throw StateError('ImageKit search is an admin operation and must run on the trusted backend.');
  }

  static String getImageUrl({required String path, int? width, int? height, bool crop = false, int quality = 80, String format = 'auto'}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final params = <String>[];
    if (width != null) params.add('w-$width');
    if (height != null) params.add('h-$height');
    if (crop) params.add('c-main');
    params.add('q-$quality');
    params.add('f-$format');
    return '$_baseUrl$normalizedPath?tr=${params.join(',')}';
  }

  static Future<String> imageToBase64(File imageFile) async {
    try {
      return base64Encode(await imageFile.readAsBytes());
    } catch (_) {
      return '';
    }
  }

  static Future<File?> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    throw StateError('ImageKit statistics are an admin operation and must run on the trusted backend.');
  }
}
