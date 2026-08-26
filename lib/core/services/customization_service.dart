import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/services/cache_service.dart';

class CustomizationService {
  static final CustomizationService _instance = CustomizationService._internal();
  factory CustomizationService() => _instance;
  CustomizationService._internal();

  final CacheService _cache = CacheService();
  SharedPreferences? _prefs;

  // الأقسام الافتراضية
  final List<String> _defaultSections = [
    'quick_services',
    'top_doctors',
    'favorites',
    'products',
    'hospitals',
    'labs',
    'pharmacies',
    'articles',
    'daily_tips',
    'discover',
    'community',
  ];

  final Map<String, String> _sectionNames = {
    'quick_services': 'خدمات سريعة',
    'top_doctors': 'أفضل الأطباء',
    'favorites': 'المفضلة ⭐',
    'products': 'منتجات صيدلية',
    'hospitals': 'مستشفيات مميزة',
    'labs': 'مختبرات مميزة',
    'pharmacies': 'صيدليات مميزة',
    'articles': 'أحدث المقالات',
    'daily_tips': 'نصائح يومية',
    'discover': 'اكتشف المزيد',
    'community': 'مجتمع صحتك',
  };

  final Map<String, IconData> _sectionIcons = {
    'quick_services': Icons.grid_view,
    'top_doctors': Icons.medical_services,
    'favorites': Icons.favorite,
    'products': Icons.shopping_bag,
    'hospitals': Icons.local_hospital,
    'labs': Icons.science,
    'pharmacies': Icons.local_pharmacy,
    'articles': Icons.article,
    'daily_tips': Icons.lightbulb,
    'discover': Icons.explore,
    'community': Icons.people,
  };

  Future<void> init() async {
    await _cache.init();
    _prefs = await SharedPreferences.getInstance();
    print('✅ CustomizationService initialized');
  }

  Future<List<String>> getVisibleSections() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      
      final sections = _prefs!.getStringList('visible_sections');
      if (sections != null && sections.isNotEmpty) {
        return sections;
      }
      
      return _defaultSections;
    } catch (e) {
      print('⚠️ Error getting visible sections: $e');
      return _defaultSections;
    }
  }

  Future<void> setVisibleSections(List<String> sections) async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs!.setStringList('visible_sections', sections);
      print('✅ Visible sections saved');
    } catch (e) {
      print('⚠️ Error saving visible sections: $e');
    }
  }

  Future<void> toggleSection(String section, bool visible) async {
    try {
      final current = await getVisibleSections();
      if (visible) {
        if (!current.contains(section)) {
          current.add(section);
        }
      } else {
        current.remove(section);
      }
      await setVisibleSections(current);
    } catch (e) {
      print('⚠️ Error toggling section: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      return {
        'theme': _prefs!.getString('theme') ?? 'light',
        'fontSize': _prefs!.getString('fontSize') ?? 'medium',
        'language': _prefs!.getString('language') ?? 'ar',
        'notifications': _prefs!.getBool('notifications') ?? true,
        'darkMode': _prefs!.getBool('darkMode') ?? false,
        'animations': _prefs!.getBool('animations') ?? true,
      };
    } catch (e) {
      print('⚠️ Error getting user preferences: $e');
      return {
        'theme': 'light',
        'fontSize': 'medium',
        'language': 'ar',
        'notifications': true,
        'darkMode': false,
        'animations': true,
      };
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      preferences.forEach((key, value) {
        if (value is String) {
          _prefs!.setString(key, value);
        } else if (value is bool) {
          _prefs!.setBool(key, value);
        } else if (value is int) {
          _prefs!.setInt(key, value);
        }
      });
      
      print('✅ User preferences updated');
    } catch (e) {
      print('⚠️ Error updating user preferences: $e');
    }
  }

  String getSectionName(String key) {
    return _sectionNames[key] ?? key;
  }

  IconData getSectionIcon(String key) {
    return _sectionIcons[key] ?? Icons.category;
  }

  List<Map<String, dynamic>> getSectionsWithStatus() async {
    final visible = await getVisibleSections();
    return _defaultSections.map((section) {
      return {
        'key': section,
        'name': getSectionName(section),
        'icon': getSectionIcon(section),
        'visible': visible.contains(section),
      };
    }).toList();
  }
}
