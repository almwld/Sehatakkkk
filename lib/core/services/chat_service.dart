import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/message_model.dart';

/// ============================================================
/// 💬 ChatService
/// ============================================================
///
/// Flutter
///   ↓
/// HTTP API
///   ↓
/// Node.js Backend
///   ↓
/// Firestore
///
/// الملفات:
/// Flutter → Backend → Nextcloud
///
/// ملاحظة:
/// يمكن تغيير العنوان أثناء التشغيل:
///
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
///
/// Android Emulator:
/// 10.0.2.2:3000
///
/// Android + Backend على نفس الجهاز:
/// 127.0.0.1:3000
/// ============================================================

class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  ChatService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// يمكن تغييره بدون تعديل الكود:
  ///
  /// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  final Map<String, Timer> _chatTimers = {};

  // ============================================================
  // 🔐 Headers
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final user = _auth.currentUser;

    if (user != null) {
      try {
        final token = await user.getIdToken();

        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        print('⚠️ تعذر الحصول على Firebase ID Token: $e');
      }
    }

    return headers;
  }

  // ============================================================
  // 🌐 HTTP helper
  // ============================================================

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: query,
      );

      final headers = await _headers();

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            uri,
            headers: headers,
          );
          break;

        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;

        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;

        default:
          throw Exception('HTTP method غير مدعوم: $method');
      }

      dynamic decoded;

      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = response.body;
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message =
            decoded is Map && decoded['message'] != null
                ? decoded['message'].toString()
                : 'HTTP ${response.statusCode}';

        throw Exception(message);
      }

      return decoded;
    } on SocketException catch (e) {
      print('❌ تعذر الاتصال بالـ Backend: $e');
      throw Exception(
        'تعذر الاتصال بخادم صحتك. تأكد من تشغيل Backend.',
      );
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } catch (e) {
      print('❌ API Error [$method $path]: $e');
      rethrow;
    }
  }

  // ============================================================
  // 🕒 تحويل Timestamp القادم من Firestore/API
  // ============================================================

  dynamic _normalizeTimestamp(dynamic value) {
    if (value == null) {
      return Timestamp.now();
    }

    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    if (value is String) {
      try {
        return Timestamp.fromDate(
          DateTime.parse(value),
        );
      } catch (_) {
        return Timestamp.now();
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

  // ============================================================
  // 🧹 تجهيز بيانات ChatModel
  // ============================================================

  Map<String, dynamic> _normalizeChatMap(
    Map<String, dynamic> data,
  ) {
    final map = Map<String, dynamic>.from(data);

    map['createdAt'] = _normalizeTimestamp(
      map['createdAt'],
    );

    map['updatedAt'] = _normalizeTimestamp(
      map['updatedAt'],
    );

    map['lastMessageTime'] = _normalizeTimestamp(
      map['lastMessageTime'],
    );

    if (map['lastSeen'] != null) {
      map['lastSeen'] = _normalizeTimestamp(
        map['lastSeen'],
      );
    }

    /// ChatModel الحالي يستخدم int وليس Map
    if (map['unreadCount'] is! int) {
      map['unreadCount'] = 0;
    }

    map['participants'] =
        List<String>.from(
          map['participants'] ?? const [],
        );

    map['labels'] =
        List<String>.from(
          map['labels'] ?? const [],
        );

    map['callHistory'] =
        List<dynamic>.from(
          map['callHistory'] ?? const [],
        );

    return map;
  }

  // ============================================================
  // 🧹 تجهيز بيانات MessageModel
  // ============================================================

  Map<String, dynamic> _normalizeMessageMap(
    Map<String, dynamic> data,
    String id,
    String chatId,
  ) {
    final map = Map<String, dynamic>.from(data);

    map['chatId'] = map['chatId'] ?? chatId;

    map['timestamp'] = _normalizeTimestamp(
      map['timestamp'],
    );

    map['senderName'] =
        map['senderName'] ?? 'مستخدم';

    map['text'] =
        map['text'] ?? '';

    map['isRead'] =
        map['isRead'] ?? false;

    map['isDelivered'] =
        map['isDelivered'] ?? false;

    map['type'] =
        map['type'] ?? 'text';

    map['isDeleted'] =
        map['isDeleted'] ?? false;

    map['isEncrypted'] =
        map['isEncrypted'] ?? false;

    map['isSelfDestruct'] =
        map['isSelfDestruct'] ?? false;

    map['selfDestructDuration'] =
        map['selfDestructDuration'] ?? 0;

    map['reactions'] =
        Map<String, int>.from(
          map['reactions'] ?? const {},
        );

    map['fileUrl'] =
        map['fileUrl'];

    map['imageUrl'] =
        map['imageUrl'];

    map['audioUrl'] =
        map['audioUrl'];

    map['locationUrl'] =
        map['locationUrl'];

    map['replyTo'] =
        map['replyTo'];

    map['replyToText'] =
        map['replyToText'];

    map['fileName'] =
        map['fileName'];

    map['fileSize'] =
        map['fileSize'];

    return map;
  }

  // ============================================================
  // 💬 إنشاء محادثة
  // ============================================================

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
      throw Exception('يجب تسجيل الدخول');
    }

    try {
      print('💬 إنشاء محادثة عبر API');
      print('👨‍⚕️ الطبيب: $doctorName ($doctorId)');
      print('👤 المريض: $patientName ($patientId)');

      final response = await _request(
        'POST',
        '/api/chats',
        body: {
          'doctorId': doctorId,
          'doctorName': doctorName,
          'doctorImage': doctorImage ?? '',
          'patientId': patientId,
          'patientName': patientName,
          'patientImage': patientImage ?? '',
        },
      );

      if (response is! Map ||
          response['success'] != true) {
        throw Exception(
          response is Map
              ? response['message'] ?? 'فشل إنشاء المحادثة'
              : 'فشل إنشاء المحادثة',
        );
      }

      final chat = response['chat'];

      if (chat is! Map || chat['id'] == null) {
        throw Exception('Backend لم يعُد chatId صحيحًا');
      }

      final chatId = chat['id'].toString();

      print(
        '✅ تم إنشاء/استرجاع المحادثة: $chatId',
      );

      return chatId;
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  // ============================================================
  // 💬 جلب المحادثات
  // ============================================================

  Stream<List<ChatModel>> getChats() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    final controller =
        StreamController<List<ChatModel>>();

    Future<void> loadChats() async {
      try {
        final response = await _request(
          'GET',
          '/api/chats',
          query: {
            'userId': user.uid,
          },
        );

        if (response is! Map ||
            response['success'] != true) {
          throw Exception('فشل جلب المحادثات');
        }

        final rawChats =
            response['chats'];

        final chats = <ChatModel>[];

        if (rawChats is List) {
          for (final item in rawChats) {
            if (item is Map) {
              try {
                final map =
                    _normalizeChatMap(
                  Map<String, dynamic>.from(item),
                );

                final id =
                    map['id']?.toString() ?? '';

                if (id.isEmpty) {
                  continue;
                }

                chats.add(
                  ChatModel.fromMap(
                    map,
                    id,
                  ),
                );
              } catch (e) {
                print(
                  '⚠️ تعذر تحويل ChatModel: $e',
                );
              }
            }
          }
        }

        chats.sort(
          (a, b) => b.lastMessageTime.compareTo(
            a.lastMessageTime,
          ),
        );

        if (!controller.isClosed) {
          controller.add(chats);
        }
      } catch (e) {
        print('❌ getChats error: $e');

        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    loadChats();

    /// محاكاة realtime عبر polling
    /// إلى أن يتم إضافة WebSocket/SSE لاحقًا.
    final timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => loadChats(),
    );

    controller.onCancel = () {
      timer.cancel();
    };

    return controller.stream;
  }

  // ============================================================
  // 💬 جلب الرسائل
  // ============================================================

  Stream<List<MessageModel>> getMessages(
    String chatId, {
    int limit = 50,
  }) {
    final controller =
        StreamController<List<MessageModel>>();

    Future<void> loadMessages() async {
      try {
        final response = await _request(
          'GET',
          '/api/chats/$chatId/messages',
          query: {
            'limit': limit.toString(),
          },
        );

        if (response is! Map ||
            response['success'] != true) {
          throw Exception('فشل جلب الرسائل');
        }

        final rawMessages =
            response['messages'];

        final messages =
            <MessageModel>[];

        if (rawMessages is List) {
          for (final item in rawMessages) {
            if (item is! Map) continue;

            try {
              final map =
                  Map<String, dynamic>.from(item);

              final id =
                  map['id']?.toString() ?? '';

              if (id.isEmpty) {
                continue;
              }

              final normalized =
                  _normalizeMessageMap(
                map,
                id,
                chatId,
              );

              messages.add(
                MessageModel.fromMap(
                  normalized,
                  id,
                ),
              );
            } catch (e) {
              print(
                '⚠️ تعذر تحويل MessageModel: $e',
              );
            }
          }
        }

        /// Backend يعيدها تنازليًا.
        /// نعيدها تصاعديًا حتى تظهر الرسائل
        /// في واجهة المحادثة بالترتيب الطبيعي.
        messages.sort(
          (a, b) =>
              a.timestamp.compareTo(
            b.timestamp,
          ),
        );

        if (!controller.isClosed) {
          controller.add(messages);
        }
      } catch (e) {
        print('❌ getMessages error: $e');

        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    loadMessages();

    final timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => loadMessages(),
    );

    controller.onCancel = () {
      timer.cancel();
    };

    return controller.stream;
  }

  // ============================================================
  // 📤 إرسال رسالة
  // ============================================================

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? replyTo,
    String? replyToText,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول');
    }

    String type = 'text';

    if (imageUrl != null &&
        imageUrl.isNotEmpty) {
      type = 'image';
    } else if (audioUrl != null &&
        audioUrl.isNotEmpty) {
      type = 'audio';
    } else if (fileUrl != null &&
        fileUrl.isNotEmpty) {
      type = 'file';
    }

    try {
      print('📤 إرسال رسالة عبر API');
      print('📱 chatId: $chatId');
      print(
        '👤 sender: ${user.uid}',
      );
      print('💬 text: $text');
      print('📦 type: $type');

      final response = await _request(
        'POST',
        '/api/chats/$chatId/messages',
        body: {
          'senderId': user.uid,
          'senderName':
              user.displayName ?? 'مستخدم',

          'text': text,

          'type': type,

          'imageUrl': imageUrl,
          'audioUrl': audioUrl,
          'fileUrl': fileUrl,

          'replyTo': replyTo,
          'replyToText': replyToText,

          'isRead': false,
          'isDelivered': true,

          'isDeleted': false,
          'isEncrypted': false,

          'isSelfDestruct': false,
          'selfDestructDuration': 0,

          'reactions': <String, int>{},

          'fileName': null,
          'fileSize': null,
        },
      );

      if (response is! Map ||
          response['success'] != true) {
        throw Exception(
          response is Map
              ? response['message'] ??
                  'فشل إرسال الرسالة'
              : 'فشل إرسال الرسالة',
        );
      }

      print('✅ تم إرسال الرسالة بنجاح');
    } catch (e) {
      print('❌ sendMessage error: $e');
      rethrow;
    }
  }

  // ============================================================
  // 📎 رفع صورة إلى Nextcloud عبر Backend
  // ============================================================

  Future<String> uploadImage({
    required String chatId,
    required File image,
  }) async {
    return _uploadFile(
      chatId: chatId,
      file: image,
      fileName:
          'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // ============================================================
  // 🎤 رفع صوت إلى Nextcloud
  // ============================================================

  Future<String> uploadAudio({
    required String chatId,
    required File audio,
  }) async {
    return _uploadFile(
      chatId: chatId,
      file: audio,
      fileName:
          'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  // ============================================================
  // 📁 رفع ملف إلى Nextcloud
  // ============================================================

  Future<String> uploadFile({
    required String chatId,
    required File file,
    required String fileName,
  }) async {
    return _uploadFile(
      chatId: chatId,
      file: file,
      fileName: fileName,
    );
  }

  // ============================================================
  // ☁️ رفع الملف فعليًا
  // ============================================================

  Future<String> _uploadFile({
    required String chatId,
    required File file,
    required String fileName,
  }) async {
    try {
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }

      final uri = Uri.parse(
        '$_baseUrl/api/files/upload',
      );

      print('☁️ رفع ملف إلى Nextcloud');
      print('📱 chatId: $chatId');
      print('📁 file: $fileName');

      final request =
          http.MultipartRequest(
        'POST',
        uri,
      );

      final user = _auth.currentUser;

      if (user != null) {
        try {
          final token =
              await user.getIdToken();

          if (token != null &&
              token.isNotEmpty) {
            request.headers['Authorization'] =
                'Bearer $token';
          }
        } catch (_) {}
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ),
      );

      request.fields['chatId'] =
          chatId;

      final streamed =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamed,
      );

      dynamic data;

      try {
        data = jsonDecode(
          response.body,
        );
      } catch (_) {
        data = null;
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final message =
            data is Map &&
                    data['message'] != null
                ? data['message'].toString()
                : 'فشل رفع الملف';

        throw Exception(message);
      }

      if (data is! Map ||
          data['success'] != true) {
        throw Exception(
          data is Map
              ? data['message'] ??
                  'فشل رفع الملف'
              : 'فشل رفع الملف',
        );
      }

      final fileData =
          data['file'];

      if (fileData is! Map) {
        throw Exception(
          'Backend لم يعُد بيانات الملف',
        );
      }

      /// Backend الحالي يعيد remotePath
      /// من Nextcloud.
      final remotePath =
          fileData['remotePath']
              ?.toString();

      if (remotePath == null ||
          remotePath.isEmpty) {
        throw Exception(
          'لم يتم الحصول على مسار الملف',
        );
      }

      print(
        '✅ تم رفع الملف: $remotePath',
      );

      return remotePath;
    } on SocketException catch (e) {
      print('❌ Upload connection error: $e');
      throw Exception(
        'تعذر الاتصال بخادم الملفات',
      );
    } catch (e) {
      print('❌ uploadFile error: $e');
      rethrow;
    }
  }

  // ============================================================
  // ✅ تحديث حالة القراءة
  // ============================================================

  Future<void> markAsRead(
    String chatId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      print(
        '👁️ تحديث حالة القراءة: $chatId',
      );

      final response = await _request(
        'PATCH',
        '/api/chats/$chatId/read',
        body: {
          'userId': user.uid,
        },
      );

      if (response is! Map ||
          response['success'] != true) {
        throw Exception(
          response is Map
              ? response['message'] ??
                  'فشل تحديث القراءة'
              : 'فشل تحديث القراءة',
        );
      }

      print(
        '✅ تم تحديث الرسائل كمقروءة',
      );
    } catch (e) {
      print('❌ markAsRead error: $e');
      rethrow;
    }
  }

  // ============================================================
  // 🧹 تنظيف
  // ============================================================

  void dispose() {
    for (final timer in _chatTimers.values) {
      timer.cancel();
    }

    _chatTimers.clear();
  }
}
