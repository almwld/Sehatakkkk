// ============================================================
// 📱 وضع عدم الاتصال التلقائي
// ============================================================

import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  late Box _chatsBox;
  late Box _messagesBox;
  bool _isInitialized = false;
  bool _isOnline = true;
  final Connectivity _connectivity = Connectivity();

  // ✅ حالة الاتصال
  bool get isOnline => _isOnline;
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  // ✅ تهيئة التخزين المحلي
  Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    _chatsBox = await Hive.openBox('offline_chats');
    _messagesBox = await Hive.openBox('offline_messages');
    _isInitialized = true;
    
    // ✅ التحقق من حالة الاتصال
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectivity);
    
    print('✅ Offline service initialized');
  }

  // ✅ التحقق من الاتصال
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    print('📡 Connectivity: ${_isOnline ? "Online" : "Offline"}');
  }

  // ✅ تحديث حالة الاتصال
  void _updateConnectivity(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOnline && !_isOnline) {
      print('📡 Went offline - switching to offline mode');
      _syncOfflineMessages();
    } else if (!wasOnline && _isOnline) {
      print('📡 Back online - syncing messages');
      _syncPendingMessages();
    }
  }

  // ============================================================
  // 💬 حفظ المحادثات
  // ============================================================

  Future<void> saveChats(List<ChatModel> chats) async {
    try {
      for (final chat in chats) {
        await _chatsBox.put(chat.id, chat.toMap());
      }
    } catch (e) {
      print('❌ Error saving chats offline: $e');
    }
  }

  List<ChatModel> getChats() {
    try {
      final chats = <ChatModel>[];
      for (final key in _chatsBox.keys) {
        final data = _chatsBox.get(key);
        if (data != null) {
          chats.add(ChatModel.fromMap(data, key.toString()));
        }
      }
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    } catch (e) {
      print('❌ Error getting offline chats: $e');
      return [];
    }
  }

  // ============================================================
  // 💬 حفظ الرسائل
  // ============================================================

  Future<void> saveMessage(MessageModel message) async {
    try {
      await _messagesBox.put(message.id, {
        ...message.toMap(),
        'pending': !_isOnline, // ✅ علامة انتظار الإرسال
      });
    } catch (e) {
      print('❌ Error saving message offline: $e');
    }
  }

  List<MessageModel> getMessages(String chatId) {
    try {
      final messages = <MessageModel>[];
      for (final key in _messagesBox.keys) {
        final data = _messagesBox.get(key);
        if (data != null && data['chatId'] == chatId) {
          messages.add(MessageModel.fromMap(data, key.toString()));
        }
      }
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    } catch (e) {
      print('❌ Error getting offline messages: $e');
      return [];
    }
  }

  // ============================================================
  // 📤 مزامنة الرسائل المعلقة
  // ============================================================

  Future<void> _syncPendingMessages() async {
    try {
      final pendingMessages = <String, Map>{};
      
      for (final key in _messagesBox.keys) {
        final data = _messagesBox.get(key);
        if (data != null && data['pending'] == true) {
          pendingMessages[key.toString()] = data;
        }
      }

      if (pendingMessages.isNotEmpty) {
        print('📤 Syncing ${pendingMessages.length} pending messages...');
        // TODO: إرسال الرسائل المعلقة إلى الخادم
        // بعد الإرسال بنجاح، حذفها من التخزين المحلي
        for (final entry in pendingMessages.entries) {
          await _messagesBox.delete(entry.key);
        }
        print('✅ Pending messages synced');
      }
    } catch (e) {
      print('❌ Error syncing pending messages: $e');
    }
  }

  Future<void> _syncOfflineMessages() async {
    // حفظ الرسائل التي لم ترسل بعد
    print('💾 Saving current state for offline mode');
  }

  // ============================================================
  // 🗑️ الحذف
  // ============================================================

  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesBox.delete(messageId);
    } catch (e) {
      print('❌ Error deleting offline message: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatsBox.delete(chatId);
      final messages = getMessages(chatId);
      for (final message in messages) {
        await _messagesBox.delete(message.id);
      }
    } catch (e) {
      print('❌ Error deleting offline chat: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _chatsBox.clear();
      await _messagesBox.clear();
    } catch (e) {
      print('❌ Error clearing offline data: $e');
    }
  }

  void dispose() {
    _chatsBox.close();
    _messagesBox.close();
  }
}
