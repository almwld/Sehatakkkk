// ============================================================
//   🖼️ دوال عرض الصور مع Placeholder
//   الملف: يمكن وضعها في lib/utils/image_utils.dart
// ============================================================

import 'package:flutter/material.dart';

/// دالة مساعدة لعرض صورة طبيب مع Placeholder
Widget buildDoctorImage(String imagePath, {double size = 55}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // ✅ صورة افتراضية عند عدم وجود الصورة
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade300, Colors.teal.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        );
      },
    ),
  );
}

/// دالة مساعدة لعرض صورة طبيب مع Placeholder (بديل)
Widget buildDoctorImageWithFallback(String imagePath, {double size = 55}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: FadeInImage.assetNetwork(
      placeholder: 'assets/images/placeholders/doctor_placeholder.png',
      image: imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person,
            color: Colors.teal.shade700,
            size: size * 0.5,
          ),
        );
      },
    ),
  );
}

/// دالة مساعدة لعرض Avatar مع Placeholder
Widget buildAvatar(String imagePath, {double size = 40}) {
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: Colors.grey.shade200,
    backgroundImage: AssetImage(imagePath),
    child: Icon(
      Icons.person,
      color: Colors.grey.shade600,
      size: size * 0.5,
    ),
    onBackgroundImageError: (error, stackTrace) {
      // ✅ يتم التعامل مع الخطأ عبر child
    },
  );
}

/// دالة مساعدة لعرض Avatar مع Placeholder (بديل)
Widget buildAvatarWithFallback(String imagePath, {double size = 40}) {
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: Colors.teal.shade100,
    child: ClipOval(
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.teal.shade100,
            child: Icon(
              Icons.person,
              color: Colors.teal.shade700,
              size: size * 0.5,
            ),
          );
        },
      ),
    ),
  );
}

/// دالة مساعدة لعرض صورة منشور مع Placeholder
Widget buildPostImage(String imagePath, {double height = 250}) {
  return Image.asset(
    imagePath,
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                color: Colors.white,
                size: height * 0.3,
              ),
              const SizedBox(height: 8),
              Text(
                'صورة غير متوفرة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// دالة مساعدة لعرض Banner مع Placeholder
Widget buildBannerImage(String imagePath, {double height = 180}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        onError: (error, stackTrace) {
          // ✅ يتم التعامل مع الخطأ عبر child
        },
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.teal.withOpacity(0.4), Colors.teal.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white.withOpacity(0.5),
          size: 50,
        ),
      ),
    ),
  );
}

/// دالة مساعدة لعرض صورة منتج مع Placeholder
Widget buildProductImage(String imagePath, {double size = 80}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.asset(
      imagePath,
      height: size,
      width: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medication,
            color: Colors.grey.shade400,
            size: size * 0.5,
          ),
        );
      },
    ),
  );
}

/// دالة مساعدة لعرض أيقونة خدمة مع Placeholder
Widget buildServiceIcon(String imagePath, {double size = 32, Color? color}) {
  return Image.asset(
    imagePath,
    width: size,
    height: size,
    errorBuilder: (context, error, stackTrace) {
      return Icon(
        Icons.circle,
        color: color ?? Colors.teal,
        size: size,
      );
    },
  );
}

/// دالة مساعدة لعرض صورة مع Placeholder (عامة)
Widget buildImageWithPlaceholder(
  String imagePath, {
  double width = double.infinity,
  double height = 200,
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
}) {
  return Image.asset(
    imagePath,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                color: Colors.grey.shade400,
                size: 40,
              ),
            ),
          );
    },
  );
}

// ============================================================
//   📦 كلاس مساعد للصور (نسخة مبسطة)
// ============================================================

class ImageHelper {
  /// عرض صورة طبيب مع Placeholder
  static Widget doctor(String path, {double size = 55}) {
    return buildDoctorImage(path, size: size);
  }

  /// عرض Avatar مع Placeholder
  static Widget avatar(String path, {double size = 40}) {
    return buildAvatar(path, size: size);
  }

  /// عرض صورة منشور مع Placeholder
  static Widget post(String path, {double height = 250}) {
    return buildPostImage(path, height: height);
  }

  /// عرض صورة منتج مع Placeholder
  static Widget product(String path, {double size = 80}) {
    return buildProductImage(path, size: size);
  }

  /// عرض Banner مع Placeholder
  static Widget banner(String path, {double height = 180}) {
    return buildBannerImage(path, height: height);
  }

  /// عرض أيقونة خدمة مع Placeholder
  static Widget serviceIcon(String path, {double size = 32, Color? color}) {
    return buildServiceIcon(path, size: size, color: color);
  }
}
