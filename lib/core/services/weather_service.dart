import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sehatak/core/services/cache_service.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final CacheService _cache = CacheService();
  static const String _cacheKey = 'weather_data';
  static const String _apiKey = 'YOUR_API_KEY'; // استخدم مفتاح API حقيقي من OpenWeatherMap

  Future<void> init() async {
    print('✅ WeatherService initialized');
  }

  Future<Map<String, dynamic>> getCurrentWeather({
    double? latitude,
    double? longitude,
    String? city,
  }) async {
    try {
      // محاولة تحميل من الكاش أولاً
      final cached = await _cache.getJson(_cacheKey);
      if (cached != null && _isCacheValid(cached)) {
        return cached;
      }

      // جلب بيانات الطقس من API
      final data = await _fetchWeatherFromAPI(latitude, longitude, city);
      await _cache.saveJson(_cacheKey, data);
      return data;
    } catch (e) {
      print('⚠️ Error fetching weather: $e');
      // إرجاع بيانات افتراضية في حالة الفشل
      return _getDefaultWeather();
    }
  }

  Future<Map<String, dynamic>> _fetchWeatherFromAPI(
    double? latitude,
    double? longitude,
    String? city,
  ) async {
    // محاكاة استدعاء API حقيقي
    // في التطبيق الحقيقي، استخدم:
    // final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric&lang=ar';
    
    // بيانات حقيقية محاكاة
    return {
      'temp': 28,
      'feels_like': 26,
      'condition': 'مشمس',
      'icon': '☀️',
      'humidity': 45,
      'wind': 12,
      'pressure': 1012,
      'uv_index': 7,
      'sunrise': '06:30',
      'sunset': '18:15',
      'city': city ?? 'صنعاء',
      'country': 'اليمن',
      'healthTip': 'استخدم واقي الشمس وشرب الماء بكثرة',
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> getForecast({double? latitude, double? longitude, String? city}) async {
    try {
      // جلب توقعات الطقس للأيام القادمة
      return [
        {
          'day': 'اليوم',
          'icon': '☀️',
          'temp': '32°C',
          'condition': 'مشمس',
          'humidity': '45%',
          'wind': '12 كم/س',
          'healthTip': 'اشرب الماء واستخدم واقي الشمس',
        },
        {
          'day': 'غداً',
          'icon': '⛅',
          'temp': '28°C',
          'condition': 'غائم جزئياً',
          'humidity': '55%',
          'wind': '18 كم/س',
          'healthTip': 'احمل مظلة تحسباً للأمطار',
        },
        {
          'day': 'بعد غد',
          'icon': '🌧️',
          'temp': '22°C',
          'condition': 'ممطر',
          'humidity': '78%',
          'wind': '25 كم/س',
          'healthTip': 'ارتدِ ملابس دافئة ومطرية',
        },
        {
          'day': 'اليوم الثالث',
          'icon': '☁️',
          'temp': '25°C',
          'condition': 'غائم',
          'humidity': '65%',
          'wind': '15 كم/س',
          'healthTip': 'أيام جيدة لممارسة الرياضة',
        },
      ];
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getHealthTipsByWeather() {
    return [
      {
        'weather': '☀️ مشمس',
        'tips': [
          'اشرب الكثير من الماء (8-10 أكواب)',
          'استخدم واقي الشمس بعامل حماية 30+',
          'ارتدِ ملابس فاتحة وقطنية',
          'تجنب التعرض للشمس في وقت الذروة (12-4 م)',
          'ارتدِ قبعة ونظارة شمسية',
        ],
        'color': '#FF9800',
      },
      {
        'weather': '☁️ غائم',
        'tips': [
          'احمل مظلة تحسباً للأمطار',
          'ارتدِ ملابس دافئة مناسبة',
          'تجنب الجلوس المطول في الأماكن المغلقة',
          'استغل الأيام الغائمة للمشي',
          'احرص على تهوية المنزل',
        ],
        'color': '#2196F3',
      },
      {
        'weather': '🌧️ ممطر',
        'tips': [
          'ارتدِ ملابس مطرية وحذاء مناسب',
          'تجنب الخروج غير الضروري',
          'احرص على التدفئة المنزلية',
          'تجنب القيادة في الطرق المبللة',
          'احرص على شرب السوائل الدافئة',
        ],
        'color': '#607D8B',
      },
    ];
  }

  bool _isCacheValid(Map<String, dynamic> cached) {
    try {
      final updatedAt = DateTime.parse(cached['updatedAt'] ?? '');
      final diff = DateTime.now().difference(updatedAt);
      return diff.inMinutes < 30; // صلاحية الكاش 30 دقيقة
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _getDefaultWeather() {
    return {
      'temp': 25,
      'feels_like': 23,
      'condition': 'غائم',
      'icon': '☁️',
      'humidity': 60,
      'wind': 10,
      'pressure': 1010,
      'uv_index': 5,
      'sunrise': '06:30',
      'sunset': '18:15',
      'city': 'صنعاء',
      'country': 'اليمن',
      'healthTip': 'احرص على شرب الماء والراحة',
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
