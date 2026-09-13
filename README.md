# صحتك - منصة رعاية صحية متكاملة

تطبيق صحي شامل للمستخدمين في اليمن، يوفر خدمات الاستشارات الطبية، حجز المواعيد، طلب الأدوية، التحاليل المخبرية، التأمين الصحي، والمزيد.

## المميزات الرئيسية

- **استشارات طبية**: تواصل مع أطباء مختصين في مختلف التخصصات
- **حجز مواعيد**: احجز مواعيدك الطبية بكل سهولة
- **الصيدلية**: اطلب الأدوية واستلمها في منزلك
- **المختبرات**: احجز التحاليل مع إمكانية الزيارة المنزلية
- **الملف الصحي**: احتفظ بسجلك الطبي كاملاً
- **التأمين الصحي**: تصفح خطط التأمين واشترك فيها
- **الطوارئ**: أرقام طوارئ وساعات إنذار
- **المحفظة**: دفع إلكتروني وإدارة المعاملات

## هيكل المشروع

```
lib/
├── core/                    # النواة (الثوابت، الثيمات، الأبعاد)
├── data/                    # البيانات (النماذج، المصادر، المستودعات)
├── domain/                  # النطاق (الكيانات، حالات الاستخدام)
├── presentation/            # العرض (BLoCs، الشاشات، الويدجت)
└── services/                # الخدمات (الإشعارات، الموقع، إلخ)
```

## التقنيات المستخدمة

- Flutter SDK 3.0+
- Dart
- BLoC Pattern (flutter_bloc)
- Dio (HTTP Client)
- Table Calendar
- Shared Preferences
- Google Fonts

## التشغيل

```bash
# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق
flutter run

# بناء APK
flutter build apk --release
```

## الترخيص

MIT License

📱 آخر تحديث: Sun Jul 19 23:36:13 +03 2026

CI verification: repaired Dart syntax is now committed on master before APK verification.

CI trigger: verify the repaired master tree with the APK workflow.

CI trigger: APK verification after restoring the truncated chat/patient sources and repairing HomeTab syntax.

CI trigger: validate the complete Dart repair including PatientDashboard.build and HomeTab brackets.

CI trigger: validate exact HomeTab doctor rating bracket fix.
