class ImageService {
  // ============================================================
  // 👨‍⚕️ صور الأطباء
  // ============================================================
  static const String doctor1 = 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&h=300&fit=crop&crop=face';
  static const String doctor2 = 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop&crop=face';
  static const String doctor3 = 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=300&h=300&fit=crop&crop=face';
  static const String doctor4 = 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&h=300&fit=crop&crop=face';

  // ============================================================
  // 📸 صور البانر
  // ============================================================
  static const String banner1 = 'https://images.unsplash.com/photo-1584982751601-97dcc096659c?w=600&h=300&fit=crop';
  static const String banner2 = 'https://images.unsplash.com/photo-1550572017-edd951b55104?w=600&h=300&fit=crop';
  static const String banner3 = 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600&h=300&fit=crop';

  // ============================================================
  // 💊 صور الأدوية
  // ============================================================
  static const String medicine1 = 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300&h=300&fit=crop';
  static const String medicine2 = 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=300&fit=crop';
  static const String medicine3 = 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=300&h=300&fit=crop';
  static const String medicine4 = 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=300&h=300&fit=crop';
  static const String medicine5 = 'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=300&h=300&fit=crop';
  static const String medicine6 = 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=300&h=300&fit=crop';
  static const String medicine7 = 'https://images.unsplash.com/photo-1518732714860-b62714ce0c59?w=300&h=300&fit=crop';
  static const String medicine8 = 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=300&h=300&fit=crop';
  static const String medicine9 = 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&h=300&fit=crop';
  static const String medicine10 = 'https://images.unsplash.com/photo-1549964472-50bd93d90cba?w=300&h=300&fit=crop';

  // ============================================================
  // 🏥 صور الصيدليات والمختبرات
  // ============================================================
  static const String pharmacy1 = 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300&h=300&fit=crop';
  static const String pharmacy2 = 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=300&fit=crop';
  static const String lab1 = 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&h=300&fit=crop';

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================
  static String getRandomDoctorImage() {
    final doctors = [doctor1, doctor2, doctor3, doctor4];
    return doctors[DateTime.now().millisecondsSinceEpoch % doctors.length];
  }

  static String getRandomBanner() {
    final banners = [banner1, banner2, banner3];
    return banners[DateTime.now().millisecondsSinceEpoch % banners.length];
  }

  static String getRandomMedicineImage() {
    final medicines = [medicine1, medicine2, medicine3, medicine4, medicine5, medicine6, medicine7, medicine8, medicine9, medicine10];
    return medicines[DateTime.now().millisecondsSinceEpoch % medicines.length];
  }

  static String getImageByType(String type) {
    switch (type) {
      case 'doctor':
        return getRandomDoctorImage();
      case 'banner':
        return getRandomBanner();
      case 'medicine':
        return getRandomMedicineImage();
      case 'pharmacy':
        return pharmacy1;
      case 'lab':
        return lab1;
      default:
        return doctor1;
    }
  }
}
