import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'message_filter_service.dart';

class MaskedChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ✅ إنشاء محادثة مقنعة
  Future<String> createMaskedChat({
    required String patientId,
    required String providerId,
    required String role, // 'pharmacy', 'lab', 'home_service'
  }) async {
    final chatId = _uuid.v4();
    
    await _firestore.collection('masked_chats').doc(chatId).set({
      'id': chatId,
      'patientId': patientId,
      'providerId': providerId,
      'role': role,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isEscrow': true,
      'paymentReleased': false,
      'messages': [],
      'order': null,
    });

    return chatId;
  }

  // ✅ إرسال رسالة مقنعة (مع فلتر)
  Future<void> sendMaskedMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    // ✅ فلترة الرسالة
    final filtered = await MessageFilterService.filterMessage(text);
    
    final messageData = {
      'id': _uuid.v4(),
      'senderId': senderId,
      'text': filtered['filtered'],
      'originalText': filtered['original'],
      'isBlocked': filtered['isBlocked'],
      'warnings': filtered['warnings'],
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    await _firestore
        .collection('masked_chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // ✅ تحديث المحادثة
    await _firestore.collection('masked_chats').doc(chatId).update({
      'lastMessage': filtered['filtered'],
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ جلب الرسائل
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('masked_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ✅ تحويل المحادثة إلى طلب (Order)
  Future<void> convertToOrder(String chatId, Map<String, dynamic> orderData) async {
    await _firestore.collection('masked_chats').doc(chatId).update({
      'order': {
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'isEscrow': true,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إصدار فاتورة (In-Chat Invoicing)
  Future<void> issueInvoice({
    required String chatId,
    required double amount,
    required String description,
    required String providerId,
  }) async {
    final invoiceId = _uuid.v4();
    
    await _firestore.collection('invoices').doc(invoiceId).set({
      'id': invoiceId,
      'chatId': chatId,
      'providerId': providerId,
      'amount': amount,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // ✅ إضافة الفاتورة كبطاقة في الشات
    await _firestore
        .collection('masked_chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'id': _uuid.v4(),
      'senderId': 'system',
      'type': 'invoice',
      'invoiceId': invoiceId,
      'amount': amount,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // ✅ إنهاء المحادثة (بعد إتمام الخدمة)
  Future<void> closeChat(String chatId) async {
    await _firestore.collection('masked_chats').doc(chatId).update({
      'status': 'completed',
      'endedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
