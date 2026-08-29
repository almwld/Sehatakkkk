// ============================================================
// 📦 نموذج التفاعل (Reaction) المتكامل
// ============================================================

class ReactionModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================

  final String messageId;
  final String chatId;
  final String userId;
  final String userName;
  final String? userImage;
  final String emoji;
  final DateTime timestamp;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================

  ReactionModel({
    required this.messageId,
    required this.chatId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.emoji,
    required this.timestamp,
  });

  // ============================================================
  // 🔄 التحويل من/إلى Map
  // ============================================================

  factory ReactionModel.fromMap(Map<String, dynamic> map) {
    return ReactionModel(
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'مستخدم',
      userImage: map['userImage'],
      emoji: map['emoji'] ?? '❤️',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'emoji': emoji,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  static List<String> get commonReactions => [
    '👍', '👎', '❤️', '🔥', '😂', '😮', '😢', '🙏', '🎉', '💯',
  ];

  static String getReactionLabel(String emoji) {
    switch (emoji) {
      case '👍': return 'أعجبني';
      case '👎': return 'لم يعجبني';
      case '❤️': return 'حب';
      case '🔥': return 'رائع';
      case '😂': return 'مضحك';
      case '😮': return 'مذهل';
      case '😢': return 'حزين';
      case '🙏': return 'شكر';
      case '🎉': return 'احتفال';
      case '💯': return 'ممتاز';
      default: return emoji;
    }
  }

  static String getReactionColor(String emoji) {
    switch (emoji) {
      case '👍': return '#4CAF50';
      case '❤️': return '#E53935';
      case '🔥': return '#FF6F00';
      case '😂': return '#FFD600';
      case '😮': return '#1A73E8';
      case '😢': return '#1A237E';
      case '🙏': return '#8D6E63';
      default: return '#757575';
    }
  }
}
