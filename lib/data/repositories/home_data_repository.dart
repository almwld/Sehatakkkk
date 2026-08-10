import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/data/models/doctor_model.dart';
import 'package:sehatak/data/models/product_model.dart';
import 'package:sehatak/data/models/hospital_model.dart';
import 'package:sehatak/data/models/lab_model.dart';
import 'package:sehatak/data/models/pharmacy_model.dart';
import 'package:sehatak/data/models/article_model.dart';
import 'package:sehatak/data/models/community_post_model.dart';
import 'package:sehatak/data/models/daily_tip_model.dart';
import 'package:flutter/material.dart';

class HomeDataRepository {
  // ============================================================
  // 👨‍⚕️ الأطباء
  // ============================================================
  static List<DoctorModel> getTopDoctors() {
    return const [
      DoctorModel(
        id: '1',
        name: 'د. أحمد المؤيد',
        specialty: 'باطنية',
        rating: 4.9,
        reviews: 328,
        image: ImageKit.doctor1,
      ),
      DoctorModel(
        id: '2',
        name: 'د. خالد النخلاني',
        specialty: 'قلبية',
        rating: 4.8,
        reviews: 256,
        image: ImageKit.doctor2,
      ),
      DoctorModel(
        id: '3',
        name: 'د. أسماء الهندي',
        specialty: 'أطفال',
        rating: 4.7,
        reviews: 189,
        image: ImageKit.doctor3,
      ),
      DoctorModel(
        id: '4',
        name: 'د. محمد العلاي',
        specialty: 'أنف وأذن وحنجرة',
        rating: 4.6,
        reviews: 89,
        image: ImageKit.doctor4,
      ),
      DoctorModel(
        id: '5',
        name: 'د. فاطمة صديقي',
        specialty: 'نساء وولادة',
        rating: 4.8,
        reviews: 210,
        image: ImageKit.doctor5,
      ),
    ];
  }

  // ============================================================
  // 💊 المنتجات
  // ============================================================
  static List<ProductModel> getProducts() {
    return const [
      ProductModel(name: 'باراسيتامول 500mg', price: 500, image: ImageKit.medicine1, category: 'مسكنات', discount: 20),
      ProductModel(name: 'فيتامين د 1000IU', price: 1200, image: ImageKit.medicine2, category: 'فيتامينات', discount: 15),
      ProductModel(name: 'جهاز قياس ضغط', price: 8500, image: ImageKit.medicine3, category: 'أجهزة طبية', discount: 10),
      ProductModel(name: 'أموكسيسيلين 500mg', price: 1500, image: ImageKit.medicine4, category: 'مضادات حيوية', discount: 0),
      ProductModel(name: 'ديكلوفيناك 50mg', price: 650, image: ImageKit.medicine1, category: 'مسكنات', discount: 5),
      ProductModel(name: 'نابروكسين 250mg', price: 550, image: ImageKit.medicine2, category: 'مضادات التهابية', discount: 10),
      ProductModel(name: 'أسبرين 100mg', price: 300, image: ImageKit.medicine3, category: 'مسكنات', discount: 0),
      ProductModel(name: 'إيبوبروفين 400mg', price: 750, image: ImageKit.medicine4, category: 'مسكنات', discount: 5),
    ];
  }

  // ============================================================
  // 🏥 المستشفيات
  // ============================================================
  static List<HospitalModel> getFeaturedHospitals() {
    return const [
      HospitalModel(id: '1', name: 'مستشفى 22 مايو', location: 'صنعاء', image: ImageKit.hospital1, rating: 4.9, specialty: 'عام', open: true),
      HospitalModel(id: '2', name: 'مستشفى آزال', location: 'صنعاء', image: ImageKit.hospital2, rating: 4.8, specialty: 'خاص', open: true),
      HospitalModel(id: '3', name: 'مستشفى السبعين', location: 'صنعاء', image: ImageKit.hospital3, rating: 4.7, specialty: 'أطفال وولادة', open: true),
      HospitalModel(id: '4', name: 'مستشفى الكويت', location: 'صنعاء', image: ImageKit.hospital4, rating: 4.8, specialty: 'جراحة', open: true),
      HospitalModel(id: '5', name: 'المستشفى الجمهوري', location: 'صنعاء', image: ImageKit.hospital5, rating: 4.6, specialty: 'حكومي', open: true),
      HospitalModel(id: '6', name: 'مستشفى الثورة العام', location: 'صنعاء', image: ImageKit.hospital6, rating: 4.5, specialty: 'حكومي', open: true),
    ];
  }

  // ============================================================
  // 🔬 المختبرات
  // ============================================================
  static List<LabModel> getFeaturedLabs() {
    return const [
      LabModel(id: '1', name: 'مختبرات الرازي', location: 'صنعاء', image: ImageKit.lab1, rating: 4.9, open: true),
      LabModel(id: '2', name: 'مختبرات العولقي', location: 'صنعاء', image: ImageKit.lab2, rating: 4.8, open: true),
      LabModel(id: '3', name: 'مختبرات المأمون', location: 'صنعاء', image: ImageKit.lab3, rating: 4.7, open: true),
      LabModel(id: '4', name: 'مختبرات الذبحاني', location: 'صنعاء', image: ImageKit.lab1, rating: 4.6, open: true),
      LabModel(id: '5', name: 'مختبرات النخبة', location: 'صنعاء', image: ImageKit.lab2, rating: 4.5, open: true),
      LabModel(id: '6', name: 'مختبرات اليمن الحديثة', location: 'صنعاء', image: ImageKit.lab3, rating: 4.4, open: true),
    ];
  }

  // ============================================================
  // 🏪 الصيدليات
  // ============================================================
  static List<PharmacyModel> getFeaturedPharmacies() {
    return const [
      PharmacyModel(id: '1', name: 'صيدلية ابن حيان', location: 'صنعاء', image: ImageKit.pharmacy1, rating: 4.9, open: true),
      PharmacyModel(id: '2', name: 'صيدلية عالم الصيدلة', location: 'صنعاء', image: ImageKit.pharmacy2, rating: 4.8, open: true),
      PharmacyModel(id: '3', name: 'صيدلية النهضة', location: 'صنعاء', image: ImageKit.pharmacy3, rating: 4.7, open: true),
      PharmacyModel(id: '4', name: 'صيدلية اليمن الحديثة', location: 'صنعاء', image: ImageKit.pharmacy1, rating: 4.6, open: true),
      PharmacyModel(id: '5', name: 'صيدلية الشفاء', location: 'صنعاء', image: ImageKit.pharmacy2, rating: 4.5, open: false),
      PharmacyModel(id: '6', name: 'صيدلية الأمانة', location: 'صنعاء', image: ImageKit.pharmacy3, rating: 4.4, open: true),
    ];
  }

  // ============================================================
  // 📰 المقالات
  // ============================================================
  static List<ArticleModel> getArticles() {
    return const [
      ArticleModel(title: 'فوائد المشي اليومي', category: 'صحة عامة', time: 'منذ ساعة', image: ImageKit.morningWalk),
      ArticleModel(title: 'نصائح لتقوية المناعة', category: 'تغذية', time: 'منذ 3 ساعات', image: ImageKit.immuneBoost),
      ArticleModel(title: 'أهمية النوم الصحي', category: 'صحة نفسية', time: 'منذ 5 ساعات', image: ImageKit.sleepTips),
      ArticleModel(title: 'العناية بالبشرة في الصيف', category: 'جلدية', time: 'منذ يوم', image: ImageKit.skinCare),
    ];
  }

  // ============================================================
  // 💡 النصائح اليومية
  // ============================================================
  static List<DailyTipModel> getDailyTips() {
    return const [
      DailyTipModel(
        title: 'شرب الماء',
        subtitle: '8 أكواب يومياً',
        icon: Icons.water_drop,
        color: AppColors.primary,
        content: 'شرب 8 أكواب من الماء يومياً يحسن صحة البشرة ويساعد في التخلص من السموم ويحسن وظائف الكلى.',
      ),
      DailyTipModel(
        title: 'المشي',
        subtitle: '30 دقيقة يومياً',
        icon: Icons.directions_walk,
        color: AppColors.primary,
        content: 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري ويعزز الصحة النفسية ويحسن جودة النوم.',
      ),
      DailyTipModel(
        title: 'النوم',
        subtitle: '7-8 ساعات ليلاً',
        icon: Icons.nights_stay,
        color: AppColors.primary,
        content: 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية ويساعد في تقوية الذاكرة والمناعة.',
      ),
      DailyTipModel(
        title: 'الفواكه',
        subtitle: '5 حصص يومياً',
        icon: Icons.apple,
        color: AppColors.primary,
        content: 'تناول 5 حصص من الفواكه والخضار يومياً يوفر الفيتامينات والمعادن الضرورية للجسم ويعزز المناعة.',
      ),
    ];
  }

  // ============================================================
  // 📝 منشورات المجتمع
  // ============================================================
  static List<CommunityPostModel> getCommunityPosts() {
    return [
      CommunityPostModel(
        id: 1,
        author: 'د. سارة العمري',
        avatar: 'س',
        image: ImageKit.skinCare,
        title: 'نصائح للعناية بالبشرة',
        content: 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.',
        likes: 120,
        comments: 15,
        shares: 8,
        time: 'منذ ساعة',
        liked: false,
        commentList: ['نصائح رائعة!', 'شكراً دكتورة', 'مفيد جداً'],
      ),
      CommunityPostModel(
        id: 2,
        author: 'د. خالد النخلاني',
        avatar: 'خ',
        image: ImageKit.morningWalk,
        title: 'فوائد المشي الصباحي',
        content: 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.',
        likes: 95,
        comments: 8,
        shares: 5,
        time: 'منذ 3 ساعات',
        liked: false,
        commentList: ['معلومة قيمة', 'سأطبقها'],
      ),
      CommunityPostModel(
        id: 3,
        author: 'د. أحمد المؤيد',
        avatar: 'أ',
        image: ImageKit.nutritionTips,
        title: 'تغذيتك سر صحتك',
        content: 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.',
        likes: 210,
        comments: 22,
        shares: 12,
        time: 'منذ 5 ساعات',
        liked: true,
        commentList: ['أحسنت', 'مفيد جداً', 'شكراً دكتور'],
      ),
      CommunityPostModel(
        id: 4,
        author: 'د. أسماء الهندي',
        avatar: 'ه',
        image: ImageKit.immuneBoost,
        title: 'قوة المناعة',
        content: 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.',
        likes: 78,
        comments: 5,
        shares: 3,
        time: 'منذ يوم',
        liked: false,
        commentList: ['معلومات مفيدة', 'شكراً'],
      ),
      CommunityPostModel(
        id: 5,
        author: 'د. محمد العلاي',
        avatar: 'م',
        image: ImageKit.sleepTips,
        title: 'نصائح النوم الصحي',
        content: 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.',
        likes: 150,
        comments: 12,
        shares: 7,
        time: 'منذ يومين',
        liked: false,
        commentList: ['سأطبق هذه النصائح', 'مفيد'],
      ),
    ];
  }
}
