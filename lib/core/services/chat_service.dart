import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../config/livekit_config.dart';
import '../models/message_model.dart';

class ChatService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: LiveKitConfig.apiBaseUrl,
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isLoggedIn => _auth.currentUser != null;

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final user = _auth.currentUser;

    if (user != null) {
      final token = await user.getIdToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();

    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);

      case 'POST':
        return http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );

      case 'PATCH':
        return http.patch(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );

      case 'DELETE':
        return http.delete(uri, headers: headers);

      default:
        throw UnsupportedError('HTTP method غير مدعوم: $method');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  Timestamp _normalizeTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return Timestamp.fromDate(parsed);
      }
    }

    if (value is Map) {
      final seconds = value['_seconds'];
      final nanoseconds = value['_nanoseconds'];

      if (seconds is num) {
        return Timestamp(
          seconds.toInt(),
          nanoseconds is num ? nanoseconds.toInt() : 0,
        );
      }
    }

    return Timestamp.now();
  }

  Map<String, dynamic> _normalizeChatMap(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);

    result['lastMessageTime'] =
        _normalizeTimestamp(result['lastMessageTime']);

    result['createdAt'] = _normalizeTimestamp(result['createdAt']);
    result['updatedAt'] = _normalizeTimestamp(result['updatedAt']);

    if (result['lastSeen'] != null) {
      result['lastSeen'] = _normalizeTimestamp(result['lastSeen']);
    }

    if (result['unreadCount'] is! num) {
      result['unreadCount'] = 0;
    }

    return result;
  }

  Map<String, dynamic> _normalizeMessageMap(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);

    result['timestamp'] = _normalizeTimestamp(result['timestamp']);

    result['chatId'] ??= '';
    result['senderName'] ??= 'مستخدم';
    result['isRead'] ??= false;
    result['isDelivered'] ??= false;
    result['isDeleted'] ??= false;
    result['isEncrypted'] ??= false;
    result['isSelfDestruct'] ??= false;
    result['selfDestructDuration'] ??= 0;
    result['reactions'] ??= <String, int>{};

    return result;
  }

  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    String? doctorImage,
    String? patientImage,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    if (doctorId.trim().isEmpty) {
      throw Exception('معرف الطبيب غير صالح');
    }

    if (doctorId.trim() == user.uid) {
      throw Exception('لا يمكن إنشاء محادثة مع المستخدم نفسه');
    }

    final response = await _request(
      'POST',
      '/api/chats',
      body: {
        'doctorId': doctorId.trim(),
        'doctorName': doctorName.trim(),
        'patientId': user.uid,
        'patientName': patientName.trim(),
        'doctorImage': doctorImage ?? '',
        'patientImage': patientImage ?? user.photoURL ?? '',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('فشل إنشاء المحادثة: ${response.statusCode}');
    }

    final data = _decodeResponse(response);
    final chat = data['chat'];

    if (chat is Map) {
      return chat['id']?.toString() ?? '';
    }

    return '';
  }

  Future<String> createTestChat() async {
    return createChat(
      doctorId: 'test-doctor',
      doctorName: 'طبيب تجريبي',
      patientId: _auth.currentUser?.uid ?? 'test-patient',
      patientName: _auth.currentUser?.displayName ?? 'مريض تجريبي',
    );
  }

  Stream<List<ChatModel>> getChats() {
    final controller = StreamController<List<ChatModel>>();
    Timer? timer;

    Future<void> load() async {
      try {
        final userId = _auth.currentUser?.uid;

        if (userId == null) {
          controller.add(<ChatModel>[]);
          return;
        }

        final response = await _request(
          'GET',
          '/api/chats',
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('فشل جلب المحادثات');
        }

        final data = _decodeResponse(response);
        final rawChats = data['chats'];

        if (rawChats is! List) {
          controller.add(<ChatModel>[]);
          return;
        }

        final chats = rawChats
            .whereType<Map>()
            .map(
              (item) => ChatModel.fromMap(
                _normalizeChatMap(
                  Map<String, dynamic>.from(item),
                ),
                item['id']?.toString() ?? '',
              ),
            )
            .toList();

        chats.sort(
          (a, b) => (b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(
            a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );

        controller.add(chats);
      } catch (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      }
    }

    load();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => load());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Stream<List<MessageModel>> getMessages(
    String chatId, {
    int limit = 50,
  }) {
    final controller = StreamController<List<MessageModel>>();
    Timer? timer;

    Future<void> load() async {
      try {
        final response = await _request(
          'GET',
          '/api/chats/${Uri.encodeComponent(chatId)}/messages?limit=$limit',
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('فشل جلب الرسائل');
        }

        final data = _decodeResponse(response);
        final rawMessages = data['messages'];

        if (rawMessages is! List) {
          controller.add(<MessageModel>[]);
          return;
        }

        final messages = rawMessages
            .whereType<Map>()
            .map(
              (item) => MessageModel.fromMap(
                _normalizeMessageMap(
                  Map<String, dynamic>.from(item),
                ),
                item['id']?.toString() ?? '',
              ),
            )
            .toList();

        messages.sort(
          (a, b) => a.timestamp.compareTo(b.timestamp),
        );

        controller.add(messages);
      } catch (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      }
    }

    load();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => load());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? replyTo,
    String? replyToText,
  }) async {
    String type = 'text';

    if (imageUrl != null && imageUrl.isNotEmpty) {
      type = 'image';
    } else if (audioUrl != null && audioUrl.isNotEmpty) {
      type = 'audio';
    } else if (fileUrl != null && fileUrl.isNotEmpty) {
      type = 'file';
    }

    final response = await _request(
      'POST',
      '/api/chats/${Uri.encodeComponent(chatId)}/messages',
      body: {
        'text': text,
        'type': type,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'fileUrl': fileUrl,
        'replyToMessageId': replyTo,
        'metadata': replyToText == null
            ? null
            : {
                'replyToText': replyToText,
              },
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('فشل إرسال الرسالة: ${response.statusCode}');
    }
  }

  Future<String> _uploadFile({
    required String chatId,
    required File file,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/files/upload');

    final request = http.MultipartRequest('POST', uri);

    final user = _auth.currentUser;

    if (user != null) {
      final token = await user.getIdToken();

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields['chatId'] = chatId;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('فشل رفع الملف: ${response.statusCode}');
    }

    final data = _decodeResponse(response);
    final uploaded = data['file'];

    if (uploaded is Map && uploaded['remotePath'] != null) {
      return uploaded['remotePath'].toString();
    }

    return '';
  }

  Future<String> uploadImage({
    required String chatId,
    required File image,
  }) {
    return _uploadFile(
      chatId: chatId,
      file: image,
    );
  }

  Future<String> uploadAudio({
    required String chatId,
    required File audio,
  }) {
    return _uploadFile(
      chatId: chatId,
      file: audio,
    );
  }

  Future<String> uploadFile({
    required String chatId,
    required File file,
    required String fileName,
  }) {
    return _uploadFile(
      chatId: chatId,
      file: file,
    );
  }

  Future<void> markAsRead(String chatId) async {
    final response = await _request(
      'PATCH',
      '/api/chats/${Uri.encodeComponent(chatId)}/read',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('فشل تحديث حالة القراءة');
    }
  }

  Future<void> deleteChat(String chatId) async {
    final response = await _request(
      'DELETE',
      '/api/chats/${Uri.encodeComponent(chatId)}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('فشل حذف المحادثة: ${response.statusCode}');
    }
  }

  void dispose() {}
}
