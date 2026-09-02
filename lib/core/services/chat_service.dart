import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _headers() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const ChatAuthenticationException(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw const ChatAuthenticationException(
        'تعذر الحصول على رمز المصادقة',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ChatModel>> getChats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chats'),
      headers: await _headers(),
    );

    _validate(response);

    final decoded = jsonDecode(response.body);

    final dynamic data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map) {
      data = decoded['chats'] ??
          decoded['data'] ??
          decoded['results'] ??
          [];
    } else {
      data = [];
    }

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => ChatModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }


  /// إنشاء محادثة جديدة عبر Backend.
  ///
  /// لا يتم إرسال patientId أو senderId من التطبيق.
  /// Backend يستخرج المستخدم الحالي من Firebase ID Token.
  Future<ChatModel> createChat({
    required String doctorId,
  }) async {
    final cleanDoctorId = doctorId.trim();

    if (cleanDoctorId.isEmpty) {
      throw const ChatValidationException(
        'معرّف الطبيب غير صالح',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/chats'),
      headers: await _headers(),
      body: jsonEncode({
        'doctorId': cleanDoctorId,
      }),
    );

    _validate(response);

    final decoded = jsonDecode(response.body);

    dynamic data = decoded;

    if (decoded is Map) {
      data = decoded['chat'] ??
          decoded['data'] ??
          decoded;
    }

    if (data is! Map) {
      throw const ChatDataException(
        'استجابة إنشاء المحادثة غير صالحة',
      );
    }

    return ChatModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<ChatModel> getChat(String chatId) async {
    _validateChatId(chatId);

    final response = await http.get(
      Uri.parse('$baseUrl/api/chats/$chatId'),
      headers: await _headers(),
    );

    _validate(response);

    final decoded = jsonDecode(response.body);

    dynamic data = decoded;

    if (decoded is Map && decoded['chat'] is Map) {
      data = decoded['chat'];
    }

    if (data is! Map) {
      throw const ChatDataException(
        'بيانات المحادثة غير صالحة',
      );
    }

    return ChatModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<List<MessageModel>> getMessages(
    String chatId, {
    int limit = 50,
  }) async {
    _validateChatId(chatId);

    final safeLimit = limit.clamp(1, 100);

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/chats/$chatId/messages'
        '?limit=$safeLimit',
      ),
      headers: await _headers(),
    );

    _validate(response);

    final decoded = jsonDecode(response.body);

    dynamic data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map) {
      data = decoded['messages'] ??
          decoded['data'] ??
          decoded['results'] ??
          [];
    } else {
      data = [];
    }

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => MessageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String chatId,
    required String text,
    String type = 'text',
    String? fileUrl,
    String? fileName,
    String? imageUrl,
    String? audioUrl,
    String? locationUrl,
    String? replyToMessageId,
  }) async {
    _validateChatId(chatId);

    final cleanText = text.trim();

    if (cleanText.isEmpty &&
        fileUrl == null &&
        imageUrl == null &&
        audioUrl == null &&
        locationUrl == null) {
      throw const ChatValidationException(
        'لا يمكن إرسال رسالة فارغة',
      );
    }

    final body = <String, dynamic>{
      'text': cleanText,
      'type': type,
    };

    if (fileUrl != null) {
      body['fileUrl'] = fileUrl;
    }

    if (fileName != null) {
      body['fileName'] = fileName;
    }

    if (imageUrl != null) {
      body['imageUrl'] = imageUrl;
    }

    if (audioUrl != null) {
      body['audioUrl'] = audioUrl;
    }

    if (locationUrl != null) {
      body['locationUrl'] = locationUrl;
    }

    if (replyToMessageId != null) {
      body['replyToMessageId'] = replyToMessageId;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/chats/$chatId/messages'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    _validate(response);

    final decoded = jsonDecode(response.body);

    dynamic data = decoded;

    if (decoded is Map && decoded['message'] is Map) {
      data = decoded['message'];
    }

    if (data is! Map) {
      throw const ChatDataException(
        'استجابة الرسالة غير صالحة',
      );
    }

    return MessageModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> markAsRead(String chatId) async {
    _validateChatId(chatId);

    final response = await http.patch(
      Uri.parse('$baseUrl/api/chats/$chatId/read'),
      headers: await _headers(),
    );

    _validate(response);
  }

  Future<void> deleteChat(String chatId) async {
    _validateChatId(chatId);

    final response = await http.delete(
      Uri.parse('$baseUrl/api/chats/$chatId'),
      headers: await _headers(),
    );

    _validate(response);
  }

  Stream<List<MessageModel>> watchMessages(
    String chatId, {
    Duration interval = const Duration(seconds: 2),
  }) async* {
    _validateChatId(chatId);

    List<MessageModel>? previous;

    while (true) {
      try {
        final current = await getMessages(chatId);

        if (!_sameMessages(previous, current)) {
          previous = current;
          yield current;
        }
      } catch (error) {
        if (previous == null) {
          rethrow;
        }
      }

      await Future<void>.delayed(interval);
    }
  }

  Stream<List<ChatModel>> watchChats({
    Duration interval = const Duration(seconds: 3),
  }) async* {
    List<ChatModel>? previous;

    while (true) {
      try {
        final current = await getChats();

        if (!_sameChats(previous, current)) {
          previous = current;
          yield current;
        }
      } catch (error) {
        if (previous == null) {
          rethrow;
        }
      }

      await Future<void>.delayed(interval);
    }
  }

  bool _sameMessages(
    List<MessageModel>? a,
    List<MessageModel> b,
  ) {
    if (a == null || a.length != b.length) {
      return false;
    }

    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].isRead != b[i].isRead ||
          a[i].isDelivered != b[i].isDelivered) {
        return false;
      }
    }

    return true;
  }

  bool _sameChats(
    List<ChatModel>? a,
    List<ChatModel> b,
  ) {
    if (a == null || a.length != b.length) {
      return false;
    }

    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].lastMessage != b[i].lastMessage ||
          a[i].unreadCount != b[i].unreadCount) {
        return false;
      }
    }

    return true;
  }

  void _validateChatId(String chatId) {
    if (chatId.trim().isEmpty) {
      throw const ChatValidationException(
        'معرّف المحادثة غير صالح',
      );
    }
  }

  void _validate(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'حدث خطأ في الخادم';

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        message = (decoded['message'] ??
                decoded['error'] ??
                message)
            .toString();
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      throw ChatAuthenticationException(message);
    }

    if (response.statusCode == 403) {
      throw ChatAuthorizationException(message);
    }

    if (response.statusCode == 404) {
      throw ChatNotFoundException(message);
    }

    throw ChatServerException(
      message,
      response.statusCode,
    );
  }
}

class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => message;
}

class ChatAuthenticationException extends ChatException {
  const ChatAuthenticationException(super.message);
}

class ChatAuthorizationException extends ChatException {
  const ChatAuthorizationException(super.message);
}

class ChatNotFoundException extends ChatException {
  const ChatNotFoundException(super.message);
}

class ChatValidationException extends ChatException {
  const ChatValidationException(super.message);
}

class ChatDataException extends ChatException {
  const ChatDataException(super.message);
}

class ChatServerException extends ChatException {
  final int statusCode;

  const ChatServerException(
    super.message,
    this.statusCode,
  );
}
