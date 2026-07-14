import 'package:flutter/material.dart';

class MedicalAI {
  static Future<String> processUserQuery(String query) async {
    // ✅ معالجة بسيطة للاستعلامات
    await Future.delayed(const Duration(milliseconds: 500));

    final lowerQuery = query.toLowerCase();

    // ✅ أعراض شائعة
    if (lowerQuery.contains('صداع') || lowerQuery.contains(' headache')) {
      return '🩺 يبدو أنك تعاني من صداع.\n\n'
          '📌 التوصيات:\n'
          '• خذ قسطاً من الراحة\n'
          '• اشرب كمية كافية من الماء\n'
          '• يمكنك استخدام مسكنات الألم مثل الباراسيتامول\n\n'
          '⚠️ إذا استمر الصداع لأكثر من 3 أيام، استشر طبيباً.';
    }

    if (lowerQuery.contains('سخونة') || lowerQuery.contains('حرارة') || lowerQuery.contains('fever')) {
      return '🌡️ يبدو أن لديك ارتفاعاً في درجة الحرارة.\n\n'
          '📌 التوصيات:\n'
          '• قم بقياس درجة حرارتك\n'
          '• اشرب سوائل دافئة\n'
          '• استخدم كمادات باردة\n\n'
          '⚠️ إذا تجاوزت الحرارة 38.5°C، استشر طبيباً.';
    }

    if (lowerQuery.contains('سكر') || lowerQuery.contains('diabetes')) {
      return '🩸 يبدو أنك تسأل عن السكري.\n\n'
          '📌 نصائح مهمة:\n'
          '• حافظ على نظام غذائي متوازن\n'
          '• تجنب السكريات المكررة\n'
          '• مارس الرياضة بانتظام\n\n'
          '📊 يجب مراقبة مستوى السكر بانتظام.';
    }

    if (lowerQuery.contains('ضغط') || lowerQuery.contains('pressure')) {
      return '❤️ يبدو أنك تسأل عن ضغط الدم.\n\n'
          '📌 نصائح مهمة:\n'
          '• قلل من تناول الملح\n'
          '• حافظ على وزن صحي\n'
          '• مارس الرياضة بانتظام\n\n'
          '📊 يجب مراقبة ضغط الدم بانتظام.';
    }

    if (lowerQuery.contains('شكرا') || lowerQuery.contains('thank')) {
      return '🙏 على الرحب والسعة!\n\n'
          'أتمنى لك دوام الصحة والعافية.\n'
          'هل هناك شيء آخر يمكنني مساعدتك به؟';
    }

    if (lowerQuery.contains('مرحبا') || lowerQuery.contains('hello') || lowerQuery.contains('hi')) {
      return '👋 مرحباً بك!\n\n'
          'كيف يمكنني مساعدتك اليوم؟\n'
          'يمكنني تقديم نصائح صحية، معلومات عن الأمراض، أو توجيهك للطبيب المناسب.';
    }

    if (lowerQuery.contains('طبيب') || lowerQuery.contains('doctor') || lowerQuery.contains('استشارة')) {
      return '👨‍⚕️ للاستشارة الطبية:\n\n'
          '📌 يمكنك:\n'
          '• حجز موعد مع طبيب من خلال التطبيق\n'
          '• استخدام خدمة الاستشارات الفورية\n'
          '• التواصل مع طبيبك عبر الدردشة\n\n'
          '🔍 اختر الخدمة المناسبة من القائمة الرئيسية.';
    }

    if (lowerQuery.contains('دواء') || lowerQuery.contains('medicine') || lowerQuery.contains('علاج')) {
      return '💊 معلومات عن الأدوية:\n\n'
          '📌 تذكر دائماً:\n'
          '• لا تتناول دواءً بدون استشارة طبية\n'
          '• التزم بالجرعات المحددة\n'
          '• احفظ الأدوية في مكان بارد وجاف\n\n'
          '💡 يمكنك طلب الأدوية من خلال قسم الصيدلية في التطبيق.';
    }

    if (lowerQuery.contains('تعب') || lowerQuery.contains('ارهاق') || lowerQuery.contains('fatigue')) {
      return '😴 يبدو أنك تعاني من التعب والإرهاق.\n\n'
          '📌 التوصيات:\n'
          '• احصل على قسط كافٍ من النوم (7-8 ساعات)\n'
          '• اشرب كمية كافية من الماء\n'
          '• مارس تمارين الاسترخاء\n\n'
          '⚠️ إذا استمر الإرهاق، استشر طبيباً.';
    }

    // ✅ رد عام
    return '🧠 شكراً على سؤالك.\n\n'
        '📌 للحصول على إجابة دقيقة، يرجى توضيح:\n'
        '• ما هي الأعراض التي تشعر بها؟\n'
        '• منذ متى وأنت تعاني؟\n'
        '• هل هناك أي حالة صحية معروفة؟\n\n'
        '💡 يمكنك أيضاً استخدام خدمات التطبيق الأخرى للحصول على مساعدة فورية.';
  }
}
