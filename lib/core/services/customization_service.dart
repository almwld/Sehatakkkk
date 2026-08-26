import 'package:shared_preferences/shared_preferences.dart';

class CustomizationService {
  static final CustomizationService _instance = CustomizationService._internal();
  factory CustomizationService() => _instance;
  CustomizationService._internal();

  SharedPreferences? _prefs;

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

  Future<void> init() async {
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

  // ✅ إزالة IconData واستخدام String بدلاً منه
  String getSectionIcon(String key) {
    final icons = {
      'quick_services': 'assets/images/services/consultation.png',
      'top_doctors': 'assets/images/services/consultation.png',
      'favorites': 'assets/images/ui/favorites.png',
      'products': 'assets/images/services/medications.png',
      'hospitals': 'assets/images/services/hospital.png',
      'labs': 'assets/images/services/laboratory.png',
      'pharmacies': 'assets/images/services/pharmacy.png',
      'articles': 'assets/images/services/medical_articles.png',
      'daily_tips': 'assets/images/services/health_tips.png',
      'discover': 'assets/images/services/packages.png',
      'community': 'assets/images/services/medical_community.png',
    };
    return icons[key] ?? 'assets/images/ui/all_services.png';
  }

  Future<List<Map<String, dynamic>>> getSectionsWithStatus() async {
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
