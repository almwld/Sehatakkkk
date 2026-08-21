import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReactionService {
  static final ReactionService _instance = ReactionService._internal();
  factory ReactionService() => _instance;
  ReactionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<String> availableReactions = [
    '👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '👏',
  ];

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final reactionRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc(user.uid);

      await reactionRef.set({
        'userId': user.uid,
        'userName': user.displayName ?? 'مستخدم',
        'emoji': emoji,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _updateReactionCount(chatId, messageId);
    } catch (e) {
      print('❌ Error adding reaction: $e');
      rethrow;
    }
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final reactionRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc(user.uid);

      final doc = await reactionRef.get();
      if (doc.exists && (doc.data()?['emoji'] as String? == emoji)) {
        await reactionRef.delete();
        await _updateReactionCount(chatId, messageId);
      }
    } catch (e) {
      print('❌ Error removing reaction: $e');
      rethrow;
    }
  }

  Future<void> toggleReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final reactionRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc(user.uid);

      final doc = await reactionRef.get();
      if (doc.exists && (doc.data()?['emoji'] as String? == emoji)) {
        await reactionRef.delete();
      } else {
        await reactionRef.set({
          'userId': user.uid,
          'userName': user.displayName ?? 'مستخدم',
          'emoji': emoji,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _updateReactionCount(chatId, messageId);
    } catch (e) {
      print('❌ Error toggling reaction: $e');
      rethrow;
    }
  }

  Future<void> _updateReactionCount(String chatId, String messageId) async {
    try {
      final reactions = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .get();

      final Map<String, int> counts = {};
      final List<String> emojis = [];

      for (final doc in reactions.docs) {
        final emoji = (doc.data()['emoji'] as String?) ?? '';
        if (emoji.isNotEmpty) {
          counts[emoji] = (counts[emoji] ?? 0) + 1;
          emojis.add(emoji);
        }
      }

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions': emojis,
        'reactionCounts': counts,
        'totalReactions': reactions.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating reaction count: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getMessageReactions({
    required String chatId,
    required String messageId,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .collection('reactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<String?> getUserReaction({
    required String chatId,
    required String messageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data()?['emoji'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user reaction: $e');
      return null;
    }
  }

  Future<void> deleteAllReactions({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final reactions = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .get();

      final batch = _firestore.batch();
      for (final doc in reactions.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions': [],
        'reactionCounts': {},
        'totalReactions': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error deleting all reactions: $e');
      rethrow;
    }
  }
}
