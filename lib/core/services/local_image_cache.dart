import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class LocalImageCache {
  static final LocalImageCache _instance = LocalImageCache._internal();
  factory LocalImageCache() => _instance;
  LocalImageCache._internal();

  final Dio _dio = Dio();
  final Map<String, String> _cache = {};

  Future<String> cacheImage(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url]!;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final file = File('${dir.path}/$fileName');
      
      if (await file.exists()) {
        _cache[url] = file.path;
        return file.path;
      }

      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data as List<int>);
      _cache[url] = file.path;
      
      return file.path;
    } catch (e) {
      return url;
    }
  }

  Future<void> clearCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();
    for (var file in files) {
      if (file is File) {
        await file.delete();
      }
    }
    _cache.clear();
  }

  Future<int> getCacheSize() async {
    final dir = await getApplicationDocumentsDirectory();
    int size = 0;
    final files = dir.listSync();
    for (var file in files) {
      if (file is File) {
        size += await file.length();
      }
    }
    return size;
  }
}
