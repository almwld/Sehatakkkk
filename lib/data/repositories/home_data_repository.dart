import 'package:sehatak/data/models/doctor_model.dart';
import 'package:sehatak/data/models/product_model.dart';
import 'package:sehatak/data/models/hospital_model.dart';
import 'package:sehatak/data/models/lab_model.dart';
import 'package:sehatak/data/models/pharmacy_model.dart';
import 'package:sehatak/data/models/article_model.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class HomeDataRepository {
  // ✅ دوال بدون const
  List<DoctorModel> getDoctorsList() {
    return [
      DoctorModel(
        id: '1',
        name: 'د. أحمد المؤيد',
        specialty: 'باطنية',
        image: ImageKit.doctor1,
        rating: 4.9,
        reviews: 328,
      ),
      DoctorModel(
        id: '2',
        name: 'د. خالد النخلاني',
        specialty: 'قلبية',
        image: ImageKit.doctor2,
        rating: 4.8,
        reviews: 256,
      ),
      DoctorModel(
        id: '3',
        name: 'د. أسماء الهندي',
        specialty: 'أطفال',
        image: ImageKit.doctor3,
        rating: 4.7,
        reviews: 189,
      ),
      DoctorModel(
        id: '4',
        name: 'د. محمد العلاي',
        specialty: 'أنف وأذن وحنجرة',
        image: ImageKit.doctor4,
        rating: 4.6,
        reviews: 89,
      ),
      DoctorModel(
        id: '5',
        name: 'د. فاطمة صديقي',
        specialty: 'نساء وولادة',
        image: ImageKit.doctor5,
        rating: 4.8,
        reviews: 210,
      ),
    ];
  }

  List<ProductModel> getProductsList() {
    return [
      ProductModel(
        name: 'باراسيتامول 500mg',
        price: 500,
        image: ImageKit.medicine1,
        category: 'مسكنات',
        discount: 20,
      ),
      ProductModel(
        name: 'فيتامين د 1000IU',
        price: 1200,
        image: ImageKit.medicine2,
        category: 'فيتامينات',
        discount: 15,
      ),
      ProductModel(
        name: 'جهاز قياس ضغط',
        price: 8500,
        image: ImageKit.medicine3,
        category: 'أجهزة طبية',
        discount: 10,
      ),
      ProductModel(
        name: 'أموكسيسيلين 500mg',
        price: 1500,
        image: ImageKit.medicine4,
        category: 'مضادات حيوية',
        discount: 0,
      ),
    ];
  }

  List<HospitalModel> getHospitalsList() {
    return [
      HospitalModel(
        id: '1',
        name: 'مستشفى 22 مايو',
        location: 'صنعاء',
        image: ImageKit.hospital1,
        rating: 4.9,
        specialty: 'عام',
        open: true,
      ),
      HospitalModel(
        id: '2',
        name: 'مستشفى آزال',
        location: 'صنعاء',
        image: ImageKit.hospital2,
        rating: 4.8,
        specialty: 'خاص',
        open: true,
      ),
      HospitalModel(
        id: '3',
        name: 'مستشفى السبعين',
        location: 'صنعاء',
        image: ImageKit.hospital3,
        rating: 4.7,
        specialty: 'أطفال وولادة',
        open: true,
      ),
      HospitalModel(
        id: '4',
        name: 'مستشفى الكويت',
        location: 'صنعاء',
        image: ImageKit.hospital4,
        rating: 4.8,
        specialty: 'جراحة',
        open: true,
      ),
      HospitalModel(
        id: '5',
        name: 'المستشفى الجمهوري',
        location: 'صنعاء',
        image: ImageKit.hospital5,
        rating: 4.6,
        specialty: 'حكومي',
        open: true,
      ),
      HospitalModel(
        id: '6',
        name: 'مستشفى الثورة العام',
        location: 'صنعاء',
        image: ImageKit.hospital6,
        rating: 4.5,
        specialty: 'حكومي',
        open: true,
      ),
    ];
  }

  List<LabModel> getLabsList() {
    return [
      LabModel(
        id: '1',
        name: 'مختبرات الرازي',
        location: 'صنعاء',
        image: ImageKit.lab1,
        rating: 4.9,
        open: true,
      ),
      LabModel(
        id: '2',
        name: 'مختبرات العولقي',
        location: 'صنعاء',
        image: ImageKit.lab2,
        rating: 4.8,
        open: true,
      ),
      LabModel(
        id: '3',
        name: 'مختبرات المأمون',
        location: 'صنعاء',
        image: ImageKit.lab3,
        rating: 4.7,
        open: true,
      ),
      LabModel(
        id: '4',
        name: 'مختبرات الذبحاني',
        location: 'صنعاء',
        image: ImageKit.lab1,
        rating: 4.6,
        open: true,
      ),
      LabModel(
        id: '5',
        name: 'مختبرات النخبة',
        location: 'صنعاء',
        image: ImageKit.lab2,
        rating: 4.5,
        open: true,
      ),
      LabModel(
        id: '6',
        name: 'مختبرات اليمن الحديثة',
        location: 'صنعاء',
        image: ImageKit.lab3,
        rating: 4.4,
        open: true,
      ),
    ];
  }

  List<PharmacyModel> getPharmaciesList() {
    return [
      PharmacyModel(
        id: '1',
        name: 'صيدلية ابن حيان',
        location: 'صنعاء',
        image: ImageKit.pharmacy1,
        rating: 4.9,
        open: true,
      ),
      PharmacyModel(
        id: '2',
        name: 'صيدلية عالم الصيدلة',
        location: 'صنعاء',
        image: ImageKit.pharmacy2,
        rating: 4.8,
        open: true,
      ),
      PharmacyModel(
        id: '3',
        name: 'صيدلية النهضة',
        location: 'صنعاء',
        image: ImageKit.pharmacy3,
        rating: 4.7,
        open: true,
      ),
      PharmacyModel(
        id: '4',
        name: 'صيدلية اليمن الحديثة',
        location: 'صنعاء',
        image: ImageKit.pharmacy1,
        rating: 4.6,
        open: true,
      ),
      PharmacyModel(
        id: '5',
        name: 'صيدلية الشفاء',
        location: 'صنعاء',
        image: ImageKit.pharmacy2,
        rating: 4.5,
        open: false,
      ),
      PharmacyModel(
        id: '6',
        name: 'صيدلية الأمانة',
        location: 'صنعاء',
        image: ImageKit.pharmacy3,
        rating: 4.4,
        open: true,
      ),
    ];
  }

  List<ArticleModel> getArticlesList() {
    return [
      ArticleModel(
        title: 'فوائد المشي اليومي',
        category: 'صحة عامة',
        time: 'منذ ساعة',
        image: ImageKit.morningWalk,
      ),
      ArticleModel(
        title: 'نصائح لتقوية المناعة',
        category: 'تغذية',
        time: 'منذ 3 ساعات',
        image: ImageKit.immuneBoost,
      ),
      ArticleModel(
        title: 'أهمية النوم الصحي',
        category: 'صحة نفسية',
        time: 'منذ 5 ساعات',
        image: ImageKit.sleepTips,
      ),
      ArticleModel(
        title: 'العناية بالبشرة في الصيف',
        category: 'جلدية',
        time: 'منذ يوم',
        image: ImageKit.skinCare,
      ),
    ];
  }

  // ✅ منشورات المجتمع
  List<Map<String, dynamic>> getCommunityPosts() {
    return [
      {
        'id': 1,
        'author': 'د. سارة العمري',
        'avatar': 'س',
        'image': ImageKit.skinCare,
        'title': 'نصائح للعناية بالبشرة',
        'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.',
        'likes': 120,
        'comments': 15,
        'shares': 8,
        'time': 'منذ ساعة',
        'liked': false,
        'commentList': ['نصائح رائعة!', 'شكراً دكتورة', 'مفيد جداً'],
      },
      {
        'id': 2,
        'author': 'د. خالد النخلاني',
        'avatar': 'خ',
        'image': ImageKit.morningWalk,
        'title': 'فوائد المشي الصباحي',
        'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.',
        'likes': 95,
        'comments': 8,
        'shares': 5,
        'time': 'منذ 3 ساعات',
        'liked': false,
        'commentList': ['معلومة قيمة', 'سأطبقها'],
      },
      {
        'id': 3,
        'author': 'د. أحمد المؤيد',
        'avatar': 'أ',
        'image': ImageKit.nutritionTips,
        'title': 'تغذيتك سر صحتك',
        'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.',
        'likes': 210,
        'comments': 22,
        'shares': 12,
        'time': 'منذ 5 ساعات',
        'liked': true,
        'commentList': ['أحسنت', 'مفيد جداً', 'شكراً دكتور'],
      },
      {
        'id': 4,
        'author': 'د. أسماء الهندي',
        'avatar': 'ه',
        'image': ImageKit.immuneBoost,
        'title': 'قوة المناعة',
        'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.',
        'likes': 78,
        'comments': 5,
        'shares': 3,
        'time': 'منذ يوم',
        'liked': false,
        'commentList': ['معلومات مفيدة', 'شكراً'],
      },
      {
        'id': 5,
        'author': 'د. محمد العلاي',
        'avatar': 'م',
        'image': ImageKit.sleepTips,
        'title': 'نصائح النوم الصحي',
        'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.',
        'likes': 150,
        'comments': 12,
        'shares': 7,
        'time': 'منذ يومين',
        'liked': false,
        'commentList': ['سأطبق هذه النصائح', 'مفيد'],
      },
    ];
  }
}
