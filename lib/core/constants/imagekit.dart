class ImageKit {
  static const String base = "https://ik.imagekit.io/fqcynk86c";
  static const String imagesBase = "$base/images";
  static const String assetsBase = "$base/assets";
  
  // ... (جميع الدوال المساعدة موجودة)
  
  // ✅ أيقونات السوشيال ميديا - المسار الصحيح (في الجذر)
  static String get socialGoogle => "$base/google.png";
  static String get socialApple => "$base/apple.png";
  static String get socialInstagram => "$base/instagram.png";
  static String get socialTwitter => "$base/x_twitter.png";
  static String get socialFacebook => "$base/facebook.png";
  static String get socialYoutube => "$base/youtube.png";
  static String get socialTiktok => "$base/tiktok.png";
  
  // ✅ أيقونات Auth (زر جوجل وآبل)
  static String get googleLogo => "$base/google.png";
  static String get appleLogo => "$base/apple.png";
}
