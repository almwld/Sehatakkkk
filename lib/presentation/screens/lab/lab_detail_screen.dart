import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_results_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_review_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';

class LabDetailScreen extends StatefulWidget {
  final String labId;

  const LabDetailScreen({super.key, required this.labId});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _lab = {};
  bool _isFavorite = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLabData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ دالة تحميل بيانات المختبر حسب الـ ID
  void _loadLabData() {
    // ✅ بيانات جميع المختبرات الـ 6
    final List<Map<String, dynamic>> allLabs = [
      {
        'id': '1',
        'name': 'مختبرات الرازي',
        'category': 'تحاليل عامة',
        'address': 'صنعاء - باب اليمن',
        'rating': 4.9,
        'reviews': 328,
        'phone': '01-234567',
        'image': ImageKit.lab1,
        'open': true,
        'price': '100-500',
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 150, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 100, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 120, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 180, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 160, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 250, 'time': '24-48 ساعة'},
        ],
        'equipment': ['ميكروسكوب رقمي', 'جهاز تحليل كيميائي', 'جهاز PCR'],
        'specialties': ['تحاليل عامة', 'كيمياء حيوية'],
        'homeService': true,
        'established': '2005',
        'description': 'أحد أفضل المختبرات في صنعاء مع كادر طبي متخصص',
        'workingHours': '8:00 ص - 8:00 م',
        'doctors': ['د. محمد الرازي', 'د. أحمد العزي'],
        'accreditations': ['معتمد من وزارة الصحة'],
        'images': [ImageKit.lab1, ImageKit.lab2, ImageKit.lab3],
        'resultsTime': '4-24 ساعة',
        'homeCollection': true,
        'insurance': ['جوبيلي', 'أدامجي'],
        'languages': ['العربية', 'الإنجليزية'],
        'parking': true,
        'wheelchair': true,
      },
      {
        'id': '2',
        'name': 'مختبرات العولقي',
        'category': 'تحاليل دقيقة',
        'address': 'صنعاء - شارع الستين',
        'rating': 4.8,
        'reviews': 256,
        'phone': '01-234568',
        'image': ImageKit.lab2,
        'open': true,
        'price': '150-600',
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 160, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 110, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 130, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 190, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 170, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 260, 'time': '24-48 ساعة'},
        ],
        'equipment': ['جهاز طيف ضوئي', 'جهاز تحليل كيميائي'],
        'specialties': ['كيمياء حيوية', 'أمراض معدية'],
        'homeService': false,
        'established': '2010',
        'description': 'مختبرات العولقي للتحاليل الدقيقة والخدمات المخبرية المتطورة',
        'workingHours': '9:00 ص - 9:00 م',
        'doctors': ['د. خالد العولقي', 'د. سامي النجار'],
        'accreditations': ['معتمد من وزارة الصحة'],
        'images': [ImageKit.lab2, ImageKit.lab3, ImageKit.lab1],
        'resultsTime': '6-48 ساعة',
        'homeCollection': false,
        'insurance': ['أدامجي'],
        'languages': ['العربية', 'الإنجليزية'],
        'parking': true,
        'wheelchair': false,
      },
      {
        'id': '3',
        'name': 'مختبرات المأمون',
        'category': 'تحاليل شاملة',
        'address': 'صنعاء - حدة',
        'rating': 4.7,
        'reviews': 189,
        'phone': '01-234569',
        'image': ImageKit.lab3,
        'open': true,
        'price': '120-550',
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 140, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 95, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 115, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 175, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 155, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 240, 'time': '24-48 ساعة'},
        ],
        'equipment': ['ميكروسكوب رقمي', 'جهاز طيف ضوئي'],
        'specialties': ['تحاليل عامة', 'أمراض معدية'],
        'homeService': true,
        'established': '2008',
        'description': 'مختبرات المأمون تقدم خدمات مخبرية عالية الدقة بأحدث التقنيات',
        'workingHours': '8:00 ص - 10:00 م',
        'doctors': ['د. عبدالله المأمون', 'د. ناصر الحمزي'],
        'accreditations': ['معتمد من وزارة الصحة', 'جودة ISO 9001'],
        'images': [ImageKit.lab3, ImageKit.lab1, ImageKit.lab2],
        'resultsTime': '4-24 ساعة',
        'homeCollection': true,
        'insurance': ['جوبيلي', 'أليانز'],
        'languages': ['العربية', 'الإنجليزية', 'الفرنسية'],
        'parking': true,
        'wheelchair': true,
      },
      {
        'id': '4',
        'name': 'مختبرات الذبحاني',
        'category': 'تحاليل عامة',
        'address': 'صنعاء - شارع الأصبحي',
        'rating': 4.6,
        'reviews': 145,
        'phone': '01-234570',
        'image': ImageKit.lab1,
        'open': true,
        'price': '100-450',
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 130, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 85, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 105, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 160, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 140, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 220, 'time': '24-48 ساعة'},
        ],
        'equipment': ['جهاز تحليل كيميائي', 'ميكروسكوب رقمي'],
        'specialties': ['تحاليل عامة'],
        'homeService': false,
        'established': '2015',
        'description': 'مختبرات الذبحاني تقدم خدمات مخبرية دقيقة بأسعار منافسة',
        'workingHours': '7:00 ص - 7:00 م',
        'doctors': ['د. علي الذبحاني', 'د. ماجد العزي'],
        'accreditations': ['معتمد من وزارة الصحة'],
        'images': [ImageKit.lab1, ImageKit.lab2, ImageKit.lab3],
        'resultsTime': '4-24 ساعة',
        'homeCollection': false,
        'insurance': ['أدامجي'],
        'languages': ['العربية'],
        'parking': false,
        'wheelchair': true,
      },
      {
        'id': '5',
        'name': 'مختبرات النخبة',
        'category': 'تحاليل متقدمة',
        'address': 'صنعاء - التحرير',
        'rating': 4.5,
        'reviews': 98,
        'phone': '01-234571',
        'image': ImageKit.lab2,
        'open': true,
        'price': '200-800',
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 200, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 120, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 150, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 220, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 200, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 300, 'time': '24-48 ساعة'},
        ],
        'equipment': ['جهاز PCR', 'جهاز طيف ضوئي'],
        'specialties': ['كيمياء حيوية', 'أمراض معدية'],
        'homeService': true,
        'established': '2020',
        'description': 'مختبرات النخبة للتحاليل المتقدمة والخدمات المخبرية الحديثة',
        'workingHours': '8:00 ص - 11:00 م',
        'doctors': ['د. هشام النخبة', 'د. ياسر الشامي'],
        'accreditations': ['معتمد من وزارة الصحة', 'جودة ISO 9001'],
        'images': [ImageKit.lab2, ImageKit.lab3, ImageKit.lab1],
        'resultsTime': '2-24 ساعة',
        'homeCollection': true,
        'insurance': ['جوبيلي', 'أدامجي', 'أليانز'],
        'languages': ['العربية', 'الإنجليزية'],
        'parking': true,
        'wheelchair': true,
      },
      {
        'id': '6',
        'name': 'مختبرات اليمن الحديثة',
        'category': 'تحاليل شاملة',
        'address': 'صنعاء - شارع الزبيري',
        'rating': 4.4,
        'reviews': 76,
        'phone': '01-234572',
        'image': ImageKit.lab3,
        'open': true,
        'price': '90-400',
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 120, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 80, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 100, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 150, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 130, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 200, 'time': '24-48 ساعة'},
        ],
        'equipment': ['ميكروسكوب رقمي', 'جهاز تحليل كيميائي'],
        'specialties': ['تحاليل عامة'],
        'homeService': false,
        'established': '2018',
        'description': 'مختبرات اليمن الحديثة تقدم خدمات مخبرية بأسعار مناسبة',
        'workingHours': '8:00 ص - 8:00 م',
        'doctors': ['د. عمر الحديثي', 'د. هاني العزي'],
        'accreditations': ['معتمد من وزارة الصحة'],
        'images': [ImageKit.lab3, ImageKit.lab1, ImageKit.lab2],
        'resultsTime': '4-48 ساعة',
        'homeCollection': false,
        'insurance': ['أدامجي'],
        'languages': ['العربية'],
        'parking': false,
        'wheelchair': false,
      },
    ];

    // ✅ البحث عن المختبر المطابق لـ widget.labId
    final lab = allLabs.firstWhere(
      (l) => l['id'] == widget.labId,
      orElse: () {
        // ✅ إذا لم يتم العثور على المختبر، عرض أول مختبر مع رسالة خطأ
        print('⚠️ لم يتم العثور على مختبر بالـ ID: ${widget.labId}، سيتم عرض المختبر الأول');
        return allLabs[0];
      },
    );
    
    _lab = lab;
  }

  // ✅ دالة للتنقل إلى شاشة حجز الفحص
  void _navigateToBooking(Map<String, dynamic> test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabBookingScreen(
          labId: _lab['id'] as String,
          testId: test['id'] as String,
        ),
      ),
    );
  }

  // ... باقي الكود (معلومات، فحوصات، أجهزة، معرض) يبقى كما هو
}
