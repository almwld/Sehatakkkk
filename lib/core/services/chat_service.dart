import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../constants/api_config.dart';
import 'auth_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final AuthService _authService = AuthService();

  // ✅ الحصول على Token
  Future<String> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');
    return await user.getIdToken() ?? '';
  }

  // ✅ Headers للمصادقة
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ✅ جلب المحادثات
  Future<List<ChatModel>> getChats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/chats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chats = data['chats'] as List? ?? [];
        return chats.map((chat) => ChatModel.fromJson(chat)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting chats: $e');
      return [];
    }
  }

  // ✅ إنشاء محادثة
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    required String patientId,
    String? doctorImage,
    String? patientImage,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientName': patientName,
        'patientId': patientId,
        'doctorImage': doctorImage,
        'patientImage': patientImage,
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chats'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chatId'] ?? data['id'] ?? '';
      }
      throw Exception('فشل إنشاء المحادثة');
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  // ✅ جلب رسائل المحادثة
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/chats/$chatId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = data['messages'] as List? ?? [];
        return messages.map((msg) => MessageModel.fromJson(msg)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting messages: $e');
      return [];
    }
  }

  // ✅ إرسال رسالة
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyTo,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'text': text,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'fileUrl': fileUrl,
        'locationUrl': locationUrl,
        'replyTo': replyTo,
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chats/$chatId/messages'),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('فشل إرسال الرسالة');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    try {
      final headers = await _getHeaders();
      await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/chats/$chatId/read'),
        headers: headers,
      );
    } catch (e) {
      print('⚠️ Error marking as read: $e');
    }
  }

  // ✅ حذف محادثة
  Future<void> deleteChat(String chatId) async {
    try {
      final headers = await _getHeaders();
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/chats/$chatId'),
        headers: headers,
      );
    } catch (e) {
      print('❌ Error deleting chat: $e');
    }
  }
}
