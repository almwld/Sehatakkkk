// ✅ دالة _loadCachedData المعدلة - تعمل فوراً بدون انتظار

Future<void> _loadCachedData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // تحميل البيانات المخزنة (إن وجدت)
    final cachedBanners = prefs.getStringList('home_banners');
    if (cachedBanners != null && cachedBanners.isNotEmpty) {
      setState(() {
        _bannerImages = cachedBanners;
        _dataLoaded = true;
        _isLoading = false;
      });
    } else {
      // استخدام البيانات الافتراضية فوراً
      _loadDefaultData();
    }
  } catch (e) {
    // في حالة الخطأ، استخدام البيانات الافتراضية
    _loadDefaultData();
  }
}
