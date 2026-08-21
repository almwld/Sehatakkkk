import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ إنشاء مجموعة جديدة
  Future<String> createGroup({
    required String name,
    required List<String> memberIds,
    String? imageUrl,
    String? description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final groupId = _firestore.collection('groups').doc().id;
    final members = [user.uid, ...memberIds.where((id) => id != user.uid)];

    final groupData = {
      'id': groupId,
      'name': name,
      'image': imageUrl ?? '',
      'description': description ?? '',
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'members': members,
      'admins': [user.uid],
      'isGroup': true,
      'lastMessage': 'تم إنشاء المجموعة',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': {},
    };

    await _firestore.collection('groups').doc(groupId).set(groupData);

    // ✅ إضافة الأعضاء كمجموعة فرعية
    for (final memberId in members) {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .set({
        'userId': memberId,
        'joinedAt': FieldValue.serverTimestamp(),
        'isAdmin': memberId == user.uid,
      });
    }

    return groupId;
  }

  // ✅ الحصول على مجموعات المستخدم
  Stream<List<Map<String, dynamic>>> getUserGroups() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('groups')
        .where('members', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ✅ الحصول على تفاصيل مجموعة
  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) return null;
      final data = doc.data();
      data?['id'] = doc.id;
      return data;
    } catch (e) {
      print('❌ Error getting group details: $e');
      return null;
    }
  }

  // ✅ إرسال رسالة في المجموعة
  Future<void> sendGroupMessage({
    required String groupId,
    required String text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageData = {
      'text': text,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': imageUrl != null ? 'image' : audioUrl != null ? 'audio' : 'text',
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isRead': {},
    };

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(messageData);

    // ✅ تحديث آخر رسالة
    final group = await getGroupDetails(groupId);
    if (group != null) {
      final members = List<String>.from(group['members'] ?? []);
      final unreadCount = Map<String, int>.from(group['unreadCount'] ?? {});
      
      for (final memberId in members) {
        if (memberId != user.uid) {
          unreadCount[memberId] = (unreadCount[memberId] ?? 0) + 1;
        }
      }

      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });
    }
  }

  // ✅ الحصول على رسائل المجموعة
  Stream<List<Map<String, dynamic>>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ✅ إضافة عضو إلى المجموعة
  Future<void> addMember({
    required String groupId,
    required String userId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    final admins = List<String>.from(group['admins'] ?? []);
    if (!admins.contains(user.uid)) {
      throw Exception('Only admins can add members');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .set({
      'userId': userId,
      'joinedAt': FieldValue.serverTimestamp(),
      'isAdmin': false,
    });
  }

  // ✅ إزالة عضو من المجموعة
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    final admins = List<String>.from(group['admins'] ?? []);
    if (!admins.contains(user.uid) && user.uid != userId) {
      throw Exception('Only admins can remove members');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .delete();

    // ✅ إذا كان العضو مشرفاً، إزالته من قائمة المشرفين
    if (admins.contains(userId)) {
      await _firestore.collection('groups').doc(groupId).update({
        'admins': FieldValue.arrayRemove([userId]),
      });
    }
  }

  // ✅ تعيين مشرف
  Future<void> makeAdmin({
    required String groupId,
    required String userId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    final admins = List<String>.from(group['admins'] ?? []);
    if (!admins.contains(user.uid)) {
      throw Exception('Only admins can make other admins');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'admins': FieldValue.arrayUnion([userId]),
    });

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .update({
      'isAdmin': true,
    });
  }

  // ✅ تغيير اسم المجموعة
  Future<void> updateGroupName({
    required String groupId,
    required String newName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    final admins = List<String>.from(group['admins'] ?? []);
    if (!admins.contains(user.uid)) {
      throw Exception('Only admins can update group name');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ تغيير صورة المجموعة
  Future<void> updateGroupImage({
    required String groupId,
    required String imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    final admins = List<String>.from(group['admins'] ?? []);
    if (!admins.contains(user.uid)) {
      throw Exception('Only admins can update group image');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'image': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ مغادرة المجموعة
  Future<void> leaveGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    final members = List<String>.from(group['members'] ?? []);
    final admins = List<String>.from(group['admins'] ?? []);

    // ✅ إذا كان آخر مشرف، تعيين مشرف جديد
    if (admins.contains(user.uid) && admins.length == 1) {
      final remainingMembers = members.where((id) => id != user.uid).toList();
      if (remainingMembers.isNotEmpty) {
        await _firestore.collection('groups').doc(groupId).update({
          'admins': [remainingMembers.first],
        });
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('members')
            .doc(remainingMembers.first)
            .update({'isAdmin': true});
      }
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([user.uid]),
    });

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(user.uid)
        .delete();

    if (admins.contains(user.uid)) {
      await _firestore.collection('groups').doc(groupId).update({
        'admins': FieldValue.arrayRemove([user.uid]),
      });
    }
  }

  // ✅ حذف المجموعة
  Future<void> deleteGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final group = await getGroupDetails(groupId);
    if (group == null) throw Exception('Group not found');

    if (group['createdBy'] != user.uid) {
      throw Exception('Only the creator can delete the group');
    }

    // ✅ حذف جميع الرسائل والأعضاء
    final messages = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    final members = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();

    for (final doc in members.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection('groups').doc(groupId));
    await batch.commit();
  }

  // ✅ تحديث حالة القراءة في المجموعة
  Future<void> markGroupMessagesAsRead(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('groups').doc(groupId).update({
      'unreadCount.${user.uid}': 0,
    });
  }
}
