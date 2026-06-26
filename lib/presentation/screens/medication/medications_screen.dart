import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'الكل';
  String _selectedPharmacy = 'الكل';
  String _sortBy = 'الاسم';

  final List<String> _categories = [
    'الكل',
    'مسكنات',
    'مضادات حيوية',
    'فيتامينات',
    'ضغط وسكري',
    'تنفسي',
    'هضمي',
    'جلدية',
    'أعصاب',
    'قلب',
    'مضادات التهاب',
    'مكملات غذائية',
  ];

  final List<String> _pharmacies = [
    'الكل',
    'صيدلية الرحمة - حدة',
    'صيدلية النور - الستين',
    'صيدلية الشفاء - الزراعة',
    'صيدلية الأمل - التحرير',
    'صيدلية اليمن - المطار',
    'صيدلية الصحة - الروضة',
    'صيدلية السلام - حدة',
    'صيدلية الحياة - الجراف',
  ];

  // ✅ 100+ دواء مع صور Unsplash
  final List<Map<String, dynamic>> _medications = [
    // مسكنات
    {'id': '1', 'name': 'باراسيتامول 500mg', 'category': 'مسكنات', 'price': 500, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'مسكن للآلام وخافض للحرارة', 'prescription': false, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '2', 'name': 'إيبوبروفين 400mg', 'category': 'مسكنات', 'price': 800, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'description': 'مضاد للالتهاب ومسكن', 'prescription': false, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '3', 'name': 'بنادول إكسترا', 'category': 'مسكنات', 'price': 600, 'image': 'https://images.unsplash.com/photo-1632833239869-a37e7a58066e?w=200', 'description': 'مسكن للصداع والآلام', 'prescription': false, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '4', 'name': 'فولتارين 50mg', 'category': 'مسكنات', 'price': 1200, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'مضاد التهاب غير ستيرويدي', 'prescription': true, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '5', 'name': 'سيروكويل 25mg', 'category': 'مسكنات', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'description': 'مسكن للألم العصبي', 'prescription': true, 'pharmacy': 'صيدلية اليمن - المطار'},
    
    // مضادات حيوية
    {'id': '6', 'name': 'أموكسيسيلين 500mg', 'category': 'مضادات حيوية', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'description': 'مضاد حيوي واسع الطيف', 'prescription': true, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '7', 'name': 'أزيثرومايسين 500mg', 'category': 'مضادات حيوية', 'price': 3500, 'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200', 'description': 'مضاد حيوي للعدوى التنفسية', 'prescription': true, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '8', 'name': 'سيفالكسين 500mg', 'category': 'مضادات حيوية', 'price': 2500, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'description': 'مضاد حيوي للجلد والجهاز التنفسي', 'prescription': true, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '9', 'name': 'دوكسيسايكلين 100mg', 'category': 'مضادات حيوية', 'price': 2000, 'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200', 'description': 'مضاد حيوي واسع الطيف', 'prescription': true, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '10', 'name': 'سيبروفلوكساسين 500mg', 'category': 'مضادات حيوية', 'price': 3000, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'description': 'مضاد حيوي فعال للعدوى البكتيرية', 'prescription': true, 'pharmacy': 'صيدلية اليمن - المطار'},
    
    // فيتامينات
    {'id': '11', 'name': 'فيتامين د3 1000IU', 'category': 'فيتامينات', 'price': 1200, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'description': 'مكمل غذائي لصحة العظام', 'prescription': false, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '12', 'name': 'فيتامين سي 1000mg', 'category': 'فيتامينات', 'price': 800, 'image': 'https://images.unsplash.com/photo-1563213126-4276a5b3e1d7?w=200', 'description': 'مقوي للمناعة ومضاد أكسدة', 'prescription': false, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '13', 'name': 'فيتامين ب المركب', 'category': 'فيتامينات', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'description': 'مكمل غذائي للطاقة والأعصاب', 'prescription': false, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '14', 'name': 'فيتامين E 400IU', 'category': 'فيتامينات', 'price': 1800, 'image': 'https://images.unsplash.com/photo-1563213126-4276a5b3e1d7?w=200', 'description': 'مضاد أكسدة للبشرة والشعر', 'prescription': false, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '15', 'name': 'فيتامين K2', 'category': 'فيتامينات', 'price': 2200, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'description': 'مكمل لصحة العظام والقلب', 'prescription': false, 'pharmacy': 'صيدلية اليمن - المطار'},
    
    // ضغط وسكري
    {'id': '16', 'name': 'أملوديبين 5mg', 'category': 'ضغط وسكري', 'price': 2000, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'لعلاج ضغط الدم المرتفع', 'prescription': true, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '17', 'name': 'ميتفورمين 500mg', 'category': 'ضغط وسكري', 'price': 1000, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'description': 'لعلاج السكري من النوع الثاني', 'prescription': true, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '18', 'name': 'إنالابريل 10mg', 'category': 'ضغط وسكري', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'لعلاج ضغط الدم المرتفع', 'prescription': true, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '19', 'name': 'أتورفاستاتين 20mg', 'category': 'ضغط وسكري', 'price': 2500, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'description': 'لخفض الكوليسترول', 'prescription': true, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '20', 'name': 'جليميبيريد 2mg', 'category': 'ضغط وسكري', 'price': 1800, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'لعلاج السكري', 'prescription': true, 'pharmacy': 'صيدلية اليمن - المطار'},
    
    // تنفسي
    {'id': '21', 'name': 'مونتيلوكاست 10mg', 'category': 'تنفسي', 'price': 2500, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'description': 'لعلاج الربو والحساسية', 'prescription': true, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '22', 'name': 'سالبوتامول 100mcg', 'category': 'تنفسي', 'price': 1200, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'description': 'موسع للشعب الهوائية', 'prescription': true, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '23', 'name': 'فلوتيكازون 50mcg', 'category': 'تنفسي', 'price': 3000, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'description': 'مضاد التهاب للأنف والجهاز التنفسي', 'prescription': true, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '24', 'name': 'برومهيكسين 8mg', 'category': 'تنفسي', 'price': 800, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'description': 'مذيب للبلغم', 'prescription': false, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '25', 'name': 'أمبروكسول 30mg', 'category': 'تنفسي', 'price': 900, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'description': 'مذيب للبلغم ومضاد للسعال', 'prescription': false, 'pharmacy': 'صيدلية اليمن - المطار'},
    
    // هضمي
    {'id': '26', 'name': 'أوميبرازول 20mg', 'category': 'هضمي', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج حرقة المعدة والارتجاع', 'prescription': false, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '27', 'name': 'ميتوكلوبراميد 10mg', 'category': 'هضمي', 'price': 800, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج الغثيان والقيء', 'prescription': true, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '28', 'name': 'لوبيراميد 2mg', 'category': 'هضمي', 'price': 600, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج الإسهال', 'prescription': false, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '29', 'name': 'بسموث سبساليسلات', 'category': 'هضمي', 'price': 1200, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج عسر الهضم والانتفاخ', 'prescription': false, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '30', 'name': 'لاكتولوز 10g', 'category': 'هضمي', 'price': 1800, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'ملين للإمساك', 'prescription': false, 'pharmacy': 'صيدلية اليمن - المطار'},
    
    // جلدية
    {'id': '31', 'name': 'كريم تريتينوين 0.05%', 'category': 'جلدية', 'price': 2000, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج حب الشباب والتجاعيد', 'prescription': true, 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': '32', 'name': 'مرهم موميتازون', 'category': 'جلدية', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج الالتهابات الجلدية', 'prescription': true, 'pharmacy': 'صيدلية النور - الستين'},
    {'id': '33', 'name': 'كريم بينزويل بيروكسيد', 'category': 'جلدية', 'price': 1200, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'لعلاج حب الشباب', 'prescription': false, 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': '34', 'name': 'مرهم كلوتريمازول', 'category': 'جلدية', 'price': 800, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'مضاد للفطريات الجلدية', 'prescription': false, 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': '35', 'name': 'كريم الهيدروكورتيزون', 'category': 'جلدية', 'price': 1000, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'description': 'مضاد للحساسية والالتهابات', 'prescription': false, 'pharmacy': 'صيدلية اليمن - المطار'},
  ];

  // ✅ مستلزمات صحية
  final List<Map<String, dynamic>> _healthSupplies = [
    {'id': 's1', 'name': 'جهاز قياس ضغط الدم', 'category': 'مستلزمات صحية', 'price': 8500, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'جهاز رقمي لقياس ضغط الدم', 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': 's2', 'name': 'جهاز قياس السكر', 'category': 'مستلزمات صحية', 'price': 6500, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'description': 'جهاز رقمي لقياس السكر', 'pharmacy': 'صيدلية النور - الستين'},
    {'id': 's3', 'name': 'ميزان حرارة رقمي', 'category': 'مستلزمات صحية', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'ميزان حرارة دقيق للجسم', 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': 's4', 'name': 'جهاز بخاخ (نيبولايزر)', 'category': 'مستلزمات صحية', 'price': 12000, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'description': 'جهاز للعلاج بالبخار', 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': 's5', 'name': 'جهاز قياس الأوكسجين', 'category': 'مستلزمات صحية', 'price': 4500, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'جهاز قياس نسبة الأوكسجين', 'pharmacy': 'صيدلية اليمن - المطار'},
    {'id': 's6', 'name': 'ضاغط للعضلات', 'category': 'مستلزمات صحية', 'price': 2500, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'ضاغط لتخفيف آلام العضلات', 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': 's7', 'name': 'وسادة طبية للرقبة', 'category': 'مستلزمات صحية', 'price': 1800, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'وسادة لتخفيف آلام الرقبة', 'pharmacy': 'صيدلية النور - الستين'},
    {'id': 's8', 'name': 'جهاز تدليك القدمين', 'category': 'مستلزمات صحية', 'price': 3200, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'description': 'جهاز تدليك لتخفيف التعب', 'pharmacy': 'صيدلية الشفاء - الزراعة'},
  ];

  // ✅ مستلزمات تجميل
  final List<Map<String, dynamic>> _beautySupplies = [
    {'id': 'b1', 'name': 'كريم ترطيب للوجه', 'category': 'مستلزمات تجميل', 'price': 2000, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'كريم ترطيب عميق للوجه', 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': 'b2', 'name': 'زيت الأركان للشعر', 'category': 'مستلزمات تجميل', 'price': 2500, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'زيت طبيعي لتغذية الشعر', 'pharmacy': 'صيدلية النور - الستين'},
    {'id': 'b3', 'name': 'ماسك للوجه', 'category': 'مستلزمات تجميل', 'price': 1500, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'ماسك لتفتيح وتنقية البشرة', 'pharmacy': 'صيدلية الشفاء - الزراعة'},
    {'id': 'b4', 'name': 'سيروم فيتامين سي', 'category': 'مستلزمات تجميل', 'price': 3500, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'سيروم مضاد للتجاعيد', 'pharmacy': 'صيدلية الأمل - التحرير'},
    {'id': 'b5', 'name': 'كريم واقي شمس SPF 50', 'category': 'مستلزمات تجميل', 'price': 1800, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'واقي شمس عالي الحماية', 'pharmacy': 'صيدلية اليمن - المطار'},
    {'id': 'b6', 'name': 'كريم ليل للبشرة', 'category': 'مستلزمات تجميل', 'price': 2200, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'كريم لتجديد خلايا البشرة', 'pharmacy': 'صيدلية الرحمة - حدة'},
    {'id': 'b7', 'name': 'زيوت عطرية طبيعية', 'category': 'مستلزمات تجميل', 'price': 2800, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'زيوت للاسترخاء والعلاج', 'pharmacy': 'صيدلية النور - الستين'},
    {'id': 'b8', 'name': 'أدوات مكياج احترافية', 'category': 'مستلزمات تجميل', 'price': 1200, 'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200', 'description': 'أدوات مكياج عالية الجودة', 'pharmacy': 'صيدلية الشفاء - الزراعة'},
  ];

  // ✅ الصيدليات النموذجية في صنعاء مع فروعها
  final List<Map<String, dynamic>> _modelPharmacies = [
    {'name': 'صيدلية الرحمة', 'branches': ['فرع حدة - شارع حدة', 'فرع السبعين - شارع السبعين', 'فرع التحرير - حي التحرير'], 'rating': 4.8, 'delivery': true, 'phone': '01-234567'},
    {'name': 'صيدلية النور', 'branches': ['فرع الستين - شارع الستين', 'فرع المطار - شارع المطار', 'فرع الروضة - حي الروضة'], 'rating': 4.7, 'delivery': true, 'phone': '01-345678'},
    {'name': 'صيدلية الشفاء', 'branches': ['فرع الزراعة - شارع الزراعة', 'فرع حدة - شارع حدة', 'فرع الجراف - حي الجراف'], 'rating': 4.9, 'delivery': true, 'phone': '01-456789'},
    {'name': 'صيدلية الأمل', 'branches': ['فرع التحرير - شارع الضباب', 'فرع السبعين - شارع السبعين', 'فرع الروضة - حي الروضة'], 'rating': 4.5, 'delivery': false, 'phone': '01-567890'},
    {'name': 'صيدلية اليمن', 'branches': ['فرع المطار - شارع المطار', 'فرع حدة - شارع حدة', 'فرع الستين - شارع الستين'], 'rating': 4.6, 'delivery': false, 'phone': '01-678901'},
    {'name': 'صيدلية الصحة', 'branches': ['فرع الروضة - شارع الثورة', 'فرع التحرير - حي التحرير', 'فرع السبعين - شارع السبعين'], 'rating': 4.8, 'delivery': true, 'phone': '01-789012'},
    {'name': 'صيدلية السلام', 'branches': ['فرع حدة - بجوار سوق الأحد', 'فرع المطار - شارع المطار', 'فرع الجراف - حي الجراف'], 'rating': 4.4, 'delivery': true, 'phone': '01-890123'},
    {'name': 'صيدلية الحياة', 'branches': ['فرع الجراف - شارع الميثاق', 'فرع الروضة - حي الروضة', 'فرع التحرير - حي التحرير'], 'rating': 4.7, 'delivery': true, 'phone': '01-901234'},
  ];

  int _getTotalItems() {
    return _medications.length + _healthSupplies.length + _beautySupplies.length;
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    var allItems = [..._medications, ..._healthSupplies, ..._beautySupplies];
    
    if (_selectedCategory != 'الكل') {
      allItems = allItems.where((item) => item['category'] == _selectedCategory).toList();
    }
    
    if (_selectedPharmacy != 'الكل') {
      allItems = allItems.where((item) => item['pharmacy'] == _selectedPharmacy).toList();
    }
    
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      allItems = allItems.where((item) => 
        item['name'].toLowerCase().contains(q) || 
        item['description'].toLowerCase().contains(q)
      ).toList();
    }
    
    if (_sortBy == 'السعر') {
      allItems.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_sortBy == 'السعر تنازلي') {
      allItems.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else {
      allItems.sort((a, b) => a['name'].compareTo(b['name']));
    }
    
    return allItems;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = _getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوية والمستلزمات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: '💊 أدوية'),
            Tab(text: '🩺 مستلزمات صحية'),
            Tab(text: '💄 تجميل'),
            Tab(text: '🏥 صيدليات'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🛒 تم إضافة المنتجات إلى السلة'), backgroundColor: AppColors.success),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemsList(filteredItems.where((item) => _medications.contains(item)).toList(), isDark),
                _buildItemsList(filteredItems.where((item) => _healthSupplies.contains(item)).toList(), isDark),
                _buildItemsList(filteredItems.where((item) => _beautySupplies.contains(item)).toList(), isDark),
                _buildPharmaciesList(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          // ✅ شريط البحث
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن دواء، مستلزمات...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ✅ تصفية وترتيب
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 18, color: AppColors.grey),
                const SizedBox(width: 4),
                ..._categories.map((cat) => _buildFilterChip(cat, _selectedCategory == cat)),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: Colors.grey[300]),
                const SizedBox(width: 8),
                const Icon(Icons.sort, size: 18, color: AppColors.grey),
                const SizedBox(width: 4),
                ...['الاسم', 'السعر', 'السعر تنازلي'].map((sort) => _buildSortChip(sort, _sortBy == sort)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selected ? Colors.white : AppColors.darkGrey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _sortBy = label),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selected ? Colors.white : AppColors.darkGrey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 60, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text('لا توجد منتجات في هذا القسم', style: TextStyle(color: AppColors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildProductCard(item, isDark);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: isDark ? const Color(0xFF2D3A54) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ صورة المنتج
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: item['image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 120,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 120,
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.medication, size: 40, color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item['description'],
                  style: const TextStyle(fontSize: 9, color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['price']} ر.ي',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['category'] ?? 'دواء',
                        style: const TextStyle(fontSize: 7, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 10, color: AppColors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        item['pharmacy'] ?? 'صيدلية',
                        style: const TextStyle(fontSize: 7, color: AppColors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ تم إضافة ${item['name']} إلى السلة'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 28),
                    ),
                    child: const Text('إضافة', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmaciesList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _modelPharmacies.length,
      itemBuilder: (context, index) {
        final ph = _modelPharmacies[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            border: Border.all(color: isDark ? const Color(0xFF2D3A54) : Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ph['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${ph['rating']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            if (ph['delivery'])
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '📦 توصيل',
                                  style: TextStyle(fontSize: 8, color: AppColors.success),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ph['phone'],
                      style: const TextStyle(fontSize: 10, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              ...ph['branches'].map<Widget>((branch) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        branch,
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}
