// ============================================================
// ☁️ خدمة Nextcloud - نسخة مبسطة
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class NextcloudService {
  static final NextcloudService _instance = NextcloudService._internal();
  factory NextcloudService() => _instance;
  NextcloudService._internal();

  String baseUrl = 'https://noa.it.tabdigital.cloud';
  String username = 'PlatformSehatak@gmail.com';
  String password = '10.10.10.1010.10.10.10';

  bool _isConnected = false;

  Future<bool> connect() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ocs/v2.php/cloud/user'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'OCS-APIRequest': 'true',
        },
      );
      _isConnected = response.statusCode == 200;
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  bool get isConnected => _isConnected;

  Future<String?> uploadImage({
    required String chatId,
    required File image,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$baseUrl/remote.php/dav/files/$username/Sehatak/$chatId/$fileName';

      final response = await http.put(
        Uri.parse(path),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'image/jpeg',
        },
        body: bytes,
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        return path;
      }
      return null;
    } catch (e) {
      print('❌ Upload image error: $e');
      return null;
    }
  }

  Future<String?> uploadAudio({
    required String chatId,
    required File audio,
  }) async {
    try {
      final bytes = await audio.readAsBytes();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '$baseUrl/remote.php/dav/files/$username/Sehatak/$chatId/$fileName';

      final response = await http.put(
        Uri.parse(path),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'audio/m4a',
        },
        body: bytes,
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        return path;
      }
      return null;
    } catch (e) {
      print('❌ Upload audio error: $e');
      return null;
    }
  }

  Future<String?> uploadFile({
    required String chatId,
    required File file,
    required String fileName,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final path = '$baseUrl/remote.php/dav/files/$username/Sehatak/$chatId/$fileName';

      final response = await http.put(
        Uri.parse(path),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        return path;
      }
      return null;
    } catch (e) {
      print('❌ Upload file error: $e');
      return null;
    }
  }

  Future<File?> downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        },
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        },
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('❌ Delete error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listFiles(String chatId) async {
    try {
      final path = '$baseUrl/remote.php/dav/files/$username/Sehatak/$chatId/';
      final client = http.Client();
      final request = http.Request('PROPFIND', Uri.parse(path));
      request.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      request.headers['Depth'] = '1';

      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 207) {
        final document = XmlDocument.parse(responseBody);
        final files = <Map<String, dynamic>>[];

        for (final element in document.findAllElements('d:response')) {
          final href = element.findElements('d:href').firstOrNull?.text ?? '';
          final propstat = element.findElements('d:propstat').firstOrNull;
          if (propstat != null) {
            final props = propstat.findElements('d:prop').firstOrNull;
            if (props != null) {
              final displayName = props.findElements('d:displayname').firstOrNull?.text ?? '';
              final getContentLength = props.findElements('d:getcontentlength').firstOrNull?.text ?? '0';
              final getLastModified = props.findElements('d:getlastmodified').firstOrNull?.text ?? '';

              if (displayName.isNotEmpty) {
                files.add({
                  'path': href,
                  'name': displayName,
                  'size': int.tryParse(getContentLength) ?? 0,
                  'modified': getLastModified,
                });
              }
            }
          }
        }
        client.close();
        return files;
      }
      return [];
    } catch (e) {
      print('❌ List files error: $e');
      return [];
    }
  }

  Map<String, String> _getHeaders() {
    final auth = base64Encode(utf8.encode('$username:$password'));
    return {
      'OCS-APIRequest': 'true',
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };
  }

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextcloud_base_url', baseUrl);
    await prefs.setString('nextcloud_username', username);
    await prefs.setString('nextcloud_password', password);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('nextcloud_base_url') ?? baseUrl;
    username = prefs.getString('nextcloud_username') ?? username;
    password = prefs.getString('nextcloud_password') ?? password;
  }

  void dispose() {
    _isConnected = false;
  }
}
