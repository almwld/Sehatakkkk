// ============================================================
// ✅ مساعد التحقق من البيانات
// ============================================================

class ValidatorHelper {
  // ============================================================
  // 📧 التحقق من البريد الإلكتروني
  // ============================================================

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!isValidEmail(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  // ============================================================
  // 🔐 التحقق من كلمة المرور
  // ============================================================

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]')) &&
           password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (!isStrongPassword(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير وصغير ورقم ورمز';
    }
    return null;
  }

  // ============================================================
  // 📱 التحقق من رقم الهاتف
  // ============================================================

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!isValidPhone(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  // ============================================================
  // 📝 التحقق من النصوص
  // ============================================================

  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String? validateNotEmpty(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'الحقل'} مطلوب';
    }
    return null;
  }

  static bool isWithinLength(String value, int min, int max) {
    return value.length >= min && value.length <= max;
  }

  static String? validateLength(String? value, int min, int max, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'الحقل'} مطلوب';
    }
    if (value.length < min) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون $min أحرف على الأقل';
    }
    if (value.length > max) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون $max أحرف كحد أقصى';
    }
    return null;
  }

  // ============================================================
  // 🎯 التحقق من التطابق
  // ============================================================

  static String? validateMatch(String? value, String? other, {String? fieldName}) {
    if (value == null || other == null) {
      return 'القيم غير متطابقة';
    }
    if (value != other) {
      return '${fieldName ?? 'القيم'} غير متطابقة';
    }
    return null;
  }

  // ============================================================
  // 📅 التحقق من التاريخ
  // ============================================================

  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static String? validateFutureDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'التاريخ'} مطلوب';
    }
    if (!isFutureDate(date)) {
      return '${fieldName ?? 'التاريخ'} يجب أن يكون في المستقبل';
    }
    return null;
  }

  static String? validatePastDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'التاريخ'} مطلوب';
    }
    if (!isPastDate(date)) {
      return '${fieldName ?? 'التاريخ'} يجب أن يكون في الماضي';
    }
    return null;
  }

  // ============================================================
  // 🔢 التحقق من الأرقام
  // ============================================================

  static bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  static bool isPositiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }

  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'القيمة'} مطلوبة';
    }
    if (!isNumeric(value)) {
      return '${fieldName ?? 'القيمة'} يجب أن تكون رقماً';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'القيمة'} مطلوبة';
    }
    if (!isPositiveNumber(value)) {
      return '${fieldName ?? 'القيمة'} يجب أن تكون رقم موجب';
    }
    return null;
  }

  // ============================================================
  // ✅ التحقق من الرابط
  // ============================================================

  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(url);
  }

  static String? validateUrl(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'الرابط'} مطلوب';
    }
    if (!isValidUrl(value)) {
      return '${fieldName ?? 'الرابط'} غير صحيح';
    }
    return null;
  }

  // ============================================================
  // 📧 التحقق من اسم المستخدم
  // ============================================================

  static bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المستخدم مطلوب';
    }
    if (!isValidUsername(value)) {
      return 'اسم المستخدم يجب أن يكون 3-20 حرفاً (a-z, A-Z, 0-9, _)';
    }
    return null;
  }
}
