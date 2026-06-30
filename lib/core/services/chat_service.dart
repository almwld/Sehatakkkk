import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

enum MessageType { text, image, file, audio, video, location, prescription }
enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final String receiverId;
  final String content;
  final MessageType type;
  MessageStatus status;
  final DateTime timestamp;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final Map<String, dynamic>? metadata;
  final String? replyTo;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhoto,
    required this.receiverId,
    required this.content,
    required this.type,
    this.status = MessageStatus.sending,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.metadata,
    this.replyTo,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderPhoto': senderPhoto,
    'receiverId': receiverId,
    'content': content,
    'type': type.name,
    'status': status.name,
    'timestamp': Timestamp.fromDate(timestamp),
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'metadata': metadata,
    'replyTo': replyTo,
    'isDeleted': isDeleted,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    id: map['id'] ?? '',
    senderId: map['senderId'] ?? '',
    senderName: map['senderName'] ?? '',
    senderPhoto: map['senderPhoto'],
    receiverId: map['receiverId'] ?? '',
    content: map['content'] ?? '',
    type: MessageType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => MessageType.text,
    ),
    status: MessageStatus.values.firstWhere(
      (e) => e.name == map['status'],
      orElse: () => MessageStatus.sent,
    ),
    timestamp: (map['timestamp'] as Timestamp).toDate(),
    fileUrl: map['fileUrl'],
    fileName: map['fileName'],
    fileSize: map['fileSize'],
    metadata: map['metadata'],
    replyTo: map['replyTo'],
    isDeleted: map['isDeleted'] ?? false,
  );
}

class ChatConversation {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final MessageType? lastMessageType;
  final String? lastSenderId;
  final Map<String, int> unreadCount;
  final bool isTyping;
  final String? typingUserId;
  final DateTime createdAt;

  ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageType,
    this.lastSenderId,
    required this.unreadCount,
    this.isTyping = false,
    this.typingUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'participants': participants,
    'participantNames': participantNames,
    'participantPhotos': participantPhotos,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime != null
        ? Timestamp.fromDate(lastMessageTime!)
        : null,
    'lastMessageType': lastMessageType?.name,
    'lastSenderId': lastSenderId,
    'unreadCount': unreadCount,
    'isTyping': isTyping,
    'typingUserId': typingUserId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ChatConversation.fromMap(Map<String, dynamic> map) => ChatConversation(
    id: map['id'] ?? '',
    participants: List<String>.from(map['participants'] ?? []),
    participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
    participantPhotos: Map<String, String?>.from(map['participantPhotos'] ?? {}),
    lastMessage: map['lastMessage'],
    lastMessageTime: map['lastMessageTime'] != null
        ? (map['lastMessageTime'] as Timestamp).toDate()
        : null,
    lastMessageType: map['lastMessageType'] != null
        ? MessageType.values.firstWhere(
            (e) => e.name == map['lastMessageType'],
            orElse: () => MessageType.text,
          )
        : null,
    lastSenderId: map['lastSenderId'],
    unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    isTyping: map['isTyping'] ?? false,
    typingUserId: map['typingUserId'],
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );

  String get otherParticipantId {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String? get otherParticipantName => participantNames[otherParticipantId];
  String? get otherParticipantPhoto => participantPhotos[otherParticipantId];
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Timer? _typingTimer;

  /// Enable offline persistence
  void enableOffline() {
    _firestore.settings = Settings(persistenceEnabled: true);
  }

  Future<ChatConversation> getOrCreateConversation(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('Not authenticated');

    final query = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        return ChatConversation.fromMap(data);
      }
    }

    final conversationId = _uuid.v4();
    final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
    final otherUserData = otherUserDoc.data() ?? {};

    final conversation = ChatConversation(
      id: conversationId,
      participants: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: _auth.currentUser?.displayName ?? 'أنت',
        otherUserId: otherUserData['name'] ?? otherUserData['fullName'] ?? 'مستخدم',
      },
      participantPhotos: {
        currentUserId: _auth.currentUser?.photoURL,
        otherUserId: otherUserData['photoUrl'] ?? otherUserData['avatar'],
      },
      unreadCount: {currentUserId: 0, otherUserId: 0},
      createdAt: DateTime.now(),
    );

    await _firestore.collection('conversations').doc(conversationId).set(conversation.toMap());
    return conversation;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String? replyTo,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final message = ChatMessage(
      id: _uuid.v4(),
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? currentUser.email ?? 'مستخدم',
      senderPhoto: currentUser.photoURL,
      receiverId: '',
      content: content,
      type: MessageType.text,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      replyTo: replyTo,
    );

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    await _updateConversation(conversationId, content, MessageType.text);

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .update({'status': MessageStatus.sent.name});
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required File imageFile,
    String? caption,
    String? replyTo,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final fileName = 'chat_${_uuid.v4()}${path.extension(imageFile.path)}';
    final ref = _storage.ref().child('chat_images/$conversationId/$fileName');
    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/${path.extension(imageFile.path).replaceFirst('.', '')}'),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    final message = ChatMessage(
      id: _uuid.v4(),
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'مستخدم',
      senderPhoto: currentUser.photoURL,
      receiverId: '',
      content: caption ?? '📷 صورة',
      type: MessageType.image,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      fileUrl: downloadUrl,
      fileName: fileName,
      replyTo: replyTo,
    );

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    await _updateConversation(conversationId, message.content, MessageType.image);
  }

  Future<void> sendFileMessage({
    required String conversationId,
    required File file,
    String? caption,
    String? replyTo,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final fileName = 'file_${_uuid.v4()}${path.extension(file.path)}';
    final ref = _storage.ref().child('chat_files/$conversationId/$fileName');
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    final fileSize = await file.length();

    final message = ChatMessage(
      id: _uuid.v4(),
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'مستخدم',
      senderPhoto: currentUser.photoURL,
      receiverId: '',
      content: caption ?? '📎 ملف',
      type: MessageType.file,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      fileUrl: downloadUrl,
      fileName: path.basename(file.path),
      fileSize: fileSize,
      replyTo: replyTo,
    );

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    await _updateConversation(conversationId, message.content, MessageType.file);
  }

  Future<void> sendAudioMessage({
    required String conversationId,
    required File audioFile,
    int durationSeconds = 0,
    String? replyTo,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final fileName = 'audio_${_uuid.v4()}.aac';
    final ref = _storage.ref().child('chat_audio/$conversationId/$fileName');
    final uploadTask = await ref.putFile(
      audioFile,
      SettableMetadata(contentType: 'audio/aac'),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    final fileSize = await audioFile.length();

    final message = ChatMessage(
      id: _uuid.v4(),
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'مستخدم',
      senderPhoto: currentUser.photoURL,
      receiverId: '',
      content: '🎵 رسالة صوتية',
      type: MessageType.audio,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      fileUrl: downloadUrl,
      fileName: fileName,
      fileSize: fileSize,
      metadata: {'duration': durationSeconds},
      replyTo: replyTo,
    );

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    await _updateConversation(conversationId, message.content, MessageType.audio);
  }

  Future<void> _updateConversation(
    String conversationId,
    String lastMessage,
    MessageType type,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final convDoc = await _firestore.collection('conversations').doc(conversationId).get();
    if (!convDoc.exists) return;

    final data = convDoc.data()!;
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUser.uid,
      orElse: () => '',
    );

    final unreadCount = Map<String, dynamic>.from(data['unreadCount'] ?? {});
    unreadCount[otherUserId] = (unreadCount[otherUserId] ?? 0) + 1;

    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.now(),
      'lastMessageType': type.name,
      'lastSenderId': currentUser.uid,
      'unreadCount': unreadCount,
    });
  }

  Future<void> markAsRead(String conversationId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final messages = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isNotEqualTo: MessageStatus.read.name)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'status': MessageStatus.read.name});
    }
    await batch.commit();

    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount.$currentUserId': 0,
    });
  }

  Future<void> setTyping(String conversationId, bool isTyping) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _typingTimer?.cancel();

    await _firestore.collection('conversations').doc(conversationId).update({
      'isTyping': isTyping,
      'typingUserId': isTyping ? currentUser.uid : null,
    });

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        setTyping(conversationId, false);
      });
    }
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isDeleted': true,
      'content': '🗑️ تم حذف هذه الرسالة',
    });
  }

  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }

  Stream<List<ChatConversation>> getConversations() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => ChatConversation.fromMap(d.data()))
            .toList());
  }

  Stream<bool> getTypingStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      if (data == null) return false;
      final typingUserId = data['typingUserId'] as String?;
      return data['isTyping'] == true &&
          typingUserId != _auth.currentUser?.uid;
    });
  }

  Stream<int> getTotalUnreadCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = Map<String, dynamic>.from(data['unreadCount'] ?? {});
        total += (unreadCount[userId] ?? 0) as int;
      }
      return total;
    });
  }
}

  // ✅ رفع الوسائط (صورة أو صوت)
  Future<String> uploadMedia(File file, String type) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = file.uri.pathSegments.last;
      final path = '${dir.path}/$fileName';
      await file.copy(path);
      print('✅ Media saved locally: $path');
      return path;
    } catch (e) {
      print('❌ Failed to save media: $e');
      rethrow;
    }
  }
