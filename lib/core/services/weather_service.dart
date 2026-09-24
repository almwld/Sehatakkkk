import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sehatak/core/services/cache_service.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();
  static const String _cacheKey = 'weather_data';

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
    double? lat = latitude, lon = longitude;
    String resolvedCity = city ?? 'صنعاء';
    if (lat == null || lon == null) {
      final geo = await http.get(Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeQueryComponent(city ?? 'صنعاء')}&count=1&language=ar&format=json'));
      if (geo.statusCode != 200) throw Exception('Weather geocoding failed');
      final results = (jsonDecode(geo.body) as Map<String, dynamic>)['results'] as List? ?? const [];
      if (results.isEmpty) throw Exception('Weather location not found');
      final first = Map<String, dynamic>.from(results.first as Map);
      lat = (first['latitude'] as num?)?.toDouble(); lon = (first['longitude'] as num?)?.toDouble();
      resolvedCity = first['name']?.toString() ?? resolvedCity;
    }
    final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,surface_pressure&forecast_days=3&timezone=auto'));
    if (response.statusCode != 200) throw Exception('Weather API failed');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final current = Map<String, dynamic>.from(decoded['current'] as Map? ?? const {});
    return {'available': true, 'temp': (current['temperature_2m'] as num?)?.toDouble(), 'feels_like': (current['apparent_temperature'] as num?)?.toDouble(), 'condition': _weatherCode(current['weather_code']), 'weatherCode': current['weather_code'], 'humidity': current['relative_humidity_2m'], 'wind': current['wind_speed_10m'], 'pressure': current['surface_pressure'], 'city': resolvedCity, 'latitude': lat, 'longitude': lon, 'updatedAt': DateTime.now().toIso8601String(), 'source': 'open-meteo'};
  }

  Future<List<Map<String, dynamic>>> getForecast({double? latitude, double? longitude, String? city}) async {
    try {
      double? lat = latitude, lon = longitude;
      if (lat == null || lon == null) {
        final geo = await http.get(Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeQueryComponent(city ?? 'صنعاء')}&count=1&language=ar&format=json'));
        if (geo.statusCode != 200) return [];
        final results = ((jsonDecode(geo.body) as Map<String, dynamic>)['results'] as List?) ?? const [];
        if (results.isEmpty) return [];
        final first = Map<String, dynamic>.from(results.first as Map);
        lat = (first['latitude'] as num?)?.toDouble(); lon = (first['longitude'] as num?)?.toDouble();
      }
      final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&forecast_days=7&timezone=auto'));
      if (response.statusCode != 200) return [];
      final daily = Map<String, dynamic>.from((jsonDecode(response.body) as Map<String, dynamic>)['daily'] as Map? ?? const {});
      final dates = List<dynamic>.from(daily['time'] as List? ?? const []), codes = List<dynamic>.from(daily['weather_code'] as List? ?? const []), max = List<dynamic>.from(daily['temperature_2m_max'] as List? ?? const []), min = List<dynamic>.from(daily['temperature_2m_min'] as List? ?? const []), rain = List<dynamic>.from(daily['precipitation_probability_max'] as List? ?? const []);
      return List.generate(dates.length, (i) => {'date': dates[i], 'weatherCode': i < codes.length ? codes[i] : null, 'condition': i < codes.length ? _weatherCode(codes[i]) : 'غير متاح', 'max': i < max.length ? max[i] : null, 'min': i < min.length ? min[i] : null, 'precipitationProbability': i < rain.length ? rain[i] : null});
    } catch (_) { return []; }
  }

  List<Map<String, dynamic>> getHealthTipsByWeather({int? weatherCode, double? temperature}) {
    final tips = <Map<String, dynamic>>[];
    if (temperature != null && temperature >= 35) tips.add({'title': 'الطقس حار', 'text': 'أكثر من شرب الماء وتجنب المجهود الطويل تحت الشمس.'});
    if (temperature != null && temperature <= 10) tips.add({'title': 'الطقس بارد', 'text': 'حافظ على الدفء وارتدِ ملابس مناسبة للطقس.'});
    if (weatherCode != null && const [51,53,55,61,63,65,80,81,82].contains(weatherCode)) tips.add({'title': 'أجواء ممطرة', 'text': 'انتبه للطرق الزلقة وخذ احتياطاتك عند الخروج.'});
    return tips;
  }

  String _weatherCode(dynamic code) {
    switch (int.tryParse(code?.toString() ?? '')) {
      case 0: return 'سماء صافية'; case 1: case 2: case 3: return 'غائم جزئياً أو غائم';
      case 45: case 48: return 'ضباب'; case 51: case 53: case 55: return 'رذاذ';
      case 61: case 63: case 65: return 'مطر'; case 71: case 73: case 75: return 'ثلوج';
      case 80: case 81: case 82: return 'زخات مطر'; case 95: case 96: case 99: return 'عواصف رعدية';
      default: return 'حالة جوية غير معروفة';
    }
  }

  bool _isCacheValid(Map<String, dynamic> data) {
    final value = DateTime.tryParse(data['updatedAt']?.toString() ?? '');
    return value != null && DateTime.now().difference(value).inMinutes < 30;
  }

  Map<String, dynamic> _getDefaultWeather() => {'available': false, 'condition': 'غير متاح', 'city': 'صنعاء', 'updatedAt': DateTime.now().toIso8601String()};
}
