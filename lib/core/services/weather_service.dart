import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sehatak/core/services/cache_service.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();
  static const String _cacheKey = 'weather_data';
  static const String _apiKey = 'YOUR_API_KEY';

  Future<void> init() async {}

  Future<Map<String, dynamic>> getCurrentWeather({double? latitude, double? longitude, String? city}) async {
    try {
      final cached = await CacheService.getJson(_cacheKey);
      if (cached != null && _isCacheValid(cached)) return cached;
      final data = await _fetchWeatherFromAPI(latitude, longitude, city);
      await CacheService.saveJson(_cacheKey, data);
      return data;
    } catch (_) { return _getDefaultWeather(); }
  }

  Future<Map<String, dynamic>> _fetchWeatherFromAPI(double? latitude, double? longitude, String? city) async {
    // لا نعيد بيانات جوية مزعومة؛ عند عدم توفر مفتاح API نعرض حالة عدم التوفر.
    if (_apiKey == 'YOUR_API_KEY') {
      return {'available': false, 'condition': 'غير متاح', 'city': city ?? 'صنعاء', 'updatedAt': DateTime.now().toIso8601String()};
    }
    final query = latitude != null && longitude != null ? 'lat=$latitude&lon=$longitude' : 'q=${Uri.encodeQueryComponent(city ?? 'Sana’a')}';
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?$query&appid=$_apiKey&units=metric&lang=ar');
    final response = await http.get(uri);
    if (response.statusCode != 200) throw Exception('Weather API ${response.statusCode}');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final main = Map<String, dynamic>.from(decoded['main'] as Map);
    final wind = Map<String, dynamic>.from(decoded['wind'] as Map? ?? const {});
    final weather = (decoded['weather'] as List?)?.isNotEmpty == true ? Map<String, dynamic>.from((decoded['weather'] as List).first as Map) : <String, dynamic>{};
    return {'available': true, 'temp': (main['temp'] as num?)?.toDouble(), 'feels_like': (main['feels_like'] as num?)?.toDouble(), 'condition': weather['description'] ?? '', 'icon': weather['icon'] ?? '', 'humidity': main['humidity'], 'wind': wind['speed'], 'pressure': main['pressure'], 'city': decoded['name'] ?? city, 'country': (decoded['sys'] as Map?)?['country'], 'updatedAt': DateTime.now().toIso8601String()};
  }

  Future<List<Map<String, dynamic>>> getForecast({double? latitude, double? longitude, String? city}) async => [];

  List<Map<String, dynamic>> getHealthTipsByWeather() => const [];

  bool _isCacheValid(Map<String, dynamic> data) {
    final value = DateTime.tryParse(data['updatedAt']?.toString() ?? '');
    return value != null && DateTime.now().difference(value).inMinutes < 30;
  }

  Map<String, dynamic> _getDefaultWeather() => {'available': false, 'condition': 'غير متاح', 'city': 'صنعاء', 'updatedAt': DateTime.now().toIso8601String()};
}
