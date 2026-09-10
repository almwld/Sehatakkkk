import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String _uid() { final id = currentUserId; if (id == null) throw Exception('يجب تسجيل الدخول'); return id; }

  Stream<List<ChatModel>> streamChats({int limit = 50}) {
    final id = _uid();
    return _firestore.collection('chats').where('participants', arrayContains: id).limit(limit).snapshots().map((s) {
      final list = s.docs.map((d) => ChatModel.fromFirestore(d.id, d.data())).toList();
      list.sort((a,b) => (b.updatedAt ?? Timestamp(0,0)).compareTo(a.updatedAt ?? Timestamp(0,0)));
      return list;
    });
  }

  Future<List<ChatModel>> getMoreChats({required int limit, DocumentSnapshot? startAfter}) async {
    final id = _uid();
    Query<Map<String,dynamic>> q = _firestore.collection('chats').where('participants', arrayContains: id).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final s = await q.get();
    return s.docs.map((d)=>ChatModel.fromFirestore(d.id,d.data())).toList();
  }

  Future<String> createChat({required String doctorId, required String doctorName, required String patientName, String? doctorImage, String? patientImage, String? idempotencyKey}) async {
    final id = _uid();
    if (doctorId.isEmpty || doctorId == id) throw Exception('معرّف الطبيب غير صالح');
    final existing = await _firestore.collection('chats').where('participants', arrayContains: id).get();
    for (final d in existing.docs) { final p=List<String>.from(d.data()['participants']??[]); if(p.length==2&&p.contains(doctorId)&&d.data()['isGroup']!=true)return d.id; }
    final ref=_firestore.collection('chats').doc();
    await ref.set({'participants':[id,doctorId],'participantDetails':{id:{'name':patientName,'photoUrl':patientImage},doctorId:{'name':doctorName,'photoUrl':doctorImage}},'lastMessage':'','lastMessageTime':null,'lastMessageSenderId':null,'unreadCount':{id:0,doctorId:0},'isGroup':false,'isArchived':false,'isPinned':false,'isMuted':false,'createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp(),if(idempotencyKey?.isNotEmpty==true)'idempotencyKey':idempotencyKey});
    return ref.id;
  }

  Future<String> sendMessage({required String chatId, required String text, String? imageUrl, String? videoUrl, String? audioUrl, String? fileUrl, String? locationUrl, String? replyToId, String? idempotencyKey, String? fileName, String? fileSize, String? fileMimeType, String? audioDuration}) async {
    final id=_uid(); final user=_auth.currentUser!; final chat=_firestore.collection('chats').doc(chatId); final doc=await chat.get(); if(!doc.exists)throw Exception('المحادثة غير موجودة');
    final participants=List<String>.from(doc.data()?['participants']??[]); if(!participants.contains(id))throw Exception('ليس لديك صلاحية لهذه المحادثة');
    if(idempotencyKey?.isNotEmpty==true){final x=await chat.collection('messages').where('idempotencyKey',isEqualTo:idempotencyKey).limit(1).get();if(x.docs.isNotEmpty)return x.docs.first.id;}
    final type=imageUrl!=null?'image':videoUrl!=null?'video':audioUrl!=null?'audio':fileUrl!=null?'file':locationUrl!=null?'location':'text';
    final preview=text.trim().isNotEmpty?text.trim():(type=='image'?'📷 صورة':type=='video'?'🎬 فيديو':type=='audio'?'🎤 رسالة صوتية':type=='file'?'📎 ملف':'مرفق');
    final ref=chat.collection('messages').doc(); final batch=_firestore.batch();
    batch.set(ref,{'chatId':chatId,'senderId':id,'senderName':user.displayName??'مستخدم','senderPhotoUrl':user.photoURL,'text':text,'type':type,'imageUrl':imageUrl,'videoUrl':videoUrl,'audioUrl':audioUrl,'fileUrl':fileUrl,'locationUrl':locationUrl,'fileName':fileName,'fileSize':fileSize,'fileMimeType':fileMimeType,'audioDuration':audioDuration,'timestamp':FieldValue.serverTimestamp(),'isRead':false,'isDelivered':true,'deliveredAt':FieldValue.serverTimestamp(),'isDeleted':false,'isEdited':false,'replyToId':replyToId,'reactions':<String,dynamic>{},if(idempotencyKey?.isNotEmpty==true)'idempotencyKey':idempotencyKey});
    final update=<String,dynamic>{'lastMessage':preview,'lastMessageTime':FieldValue.serverTimestamp(),'lastMessageSenderId':id,'updatedAt':FieldValue.serverTimestamp()}; for(final p in participants)if(p!=id)update['unreadCount.$p']=FieldValue.increment(1); batch.update(chat,update); await batch.commit(); return ref.id;
  }

  Future<String> sendSystemMessage({required String chatId,required String text,String? idempotencyKey,Map<String,dynamic>? metadata}) async { return sendMessage(chatId:chatId,text:text,idempotencyKey:idempotencyKey); }

  Stream<MessagePaginationResult> streamMessages(String chatId,{int limit=30}) { _uid(); return _firestore.collection('chats').doc(chatId).collection('messages').orderBy('timestamp',descending:true).limit(limit).snapshots().map((s)=>MessagePaginationResult(messages:s.docs.map((d)=>MessageModel.fromFirestore(d.id,d.data())).toList(),lastDocument:s.docs.isNotEmpty?s.docs.last:null,hasMore:s.docs.length>=limit)); }

  Future<MessagePaginationResult> getMoreMessages({required String chatId,required int limit,DocumentSnapshot? startAfter}) async {
    _uid();
    Query<Map<String,dynamic>> q=_firestore.collection('chats').doc(chatId).collection('messages').orderBy('timestamp',descending:true).limit(limit);
    if(startAfter!=null)q=q.startAfterDocument(startAfter);
    final s=await q.get();
    return MessagePaginationResult(messages:s.docs.map((d)=>MessageModel.fromFirestore(d.id,d.data())).toList(),lastDocument:s.docs.isNotEmpty?s.docs.last:null,hasMore:s.docs.length>=limit);
  }

  Future<void> archiveChat(String chatId, bool archived) async { _uid(); await _firestore.collection('chats').doc(chatId).update({'isArchived':archived,'updatedAt':FieldValue.serverTimestamp()}); }
  Future<void> pinChat(String chatId, bool pinned) async { _uid(); await _firestore.collection('chats').doc(chatId).update({'isPinned':pinned,'updatedAt':FieldValue.serverTimestamp()}); }
  Future<void> muteChat(String chatId, bool muted) async { _uid(); await _firestore.collection('chats').doc(chatId).update({'isMuted':muted,'updatedAt':FieldValue.serverTimestamp()}); }
  Future<void> deleteMessage(String chatId, String messageId) async { final id=_uid(); final ref=_firestore.collection('chats').doc(chatId).collection('messages').doc(messageId); final d=await ref.get(); if(!d.exists||d.data()?['senderId']!=id)throw Exception('لا يمكن حذف الرسالة'); await ref.update({'isDeleted':true,'type':'deleted','text':'تم حذف هذه الرسالة'}); }
  Future<void> addReaction(String chatId, String messageId, String reaction) async { final id=_uid(); if(reaction.trim().isEmpty)return; await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({'reactions.$id':reaction}); }
  Future<void> markAsRead(String chatId) async { final id=_uid(); final chat=_firestore.collection('chats').doc(chatId); final s=await chat.collection('messages').where('senderId',isNotEqualTo:id).where('isRead',isEqualTo:false).limit(100).get(); final b=_firestore.batch(); for(final d in s.docs)b.update(d.reference,{'isRead':true,'readAt':FieldValue.serverTimestamp()}); b.update(chat,{'unreadCount.$id':0}); await b.commit(); }
}

class MessagePaginationResult {
  final List<MessageModel> messages;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  MessagePaginationResult({required this.messages,this.lastDocument,required this.hasMore});
}
