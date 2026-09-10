import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

import '../../firebase_options.dart';
import 'chat_service.dart';
import 'nextcloud_service.dart';

const String chatMediaTransferTask = 'sehatak.chat.media.transfer';

@pragma('vm:entry-point')
void chatMediaTransferCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final service = ChatMediaTransferService.instance;
      await service.initialize(startBackgroundWorker: false);
      await service.processPending();
      return true;
    } catch (_) {
      return false;
    }
  });
}

/// Persistent media outbox for chat attachments.
///
/// The chat UI can display the persistent local file immediately. This queue
/// survives widget rebuilds and app restarts, then uploads/verifies/sends when
/// a network connection is available. Firestore remains the source of truth
/// after send.
class ChatMediaTransferService {
  ChatMediaTransferService._();
  static final ChatMediaTransferService instance = ChatMediaTransferService._();

  Database? _db;
  StreamSubscription<dynamic>? _connectivitySub;
  bool _processing = false;
  bool _workerInitialized = false;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      p.join(root, 'sehatak_chat_outbox.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE media_outbox (
            id TEXT PRIMARY KEY,
            chat_id TEXT NOT NULL,
            local_path TEXT NOT NULL,
            type TEXT NOT NULL,
            folder TEXT NOT NULL,
            preview TEXT NOT NULL,
            file_name TEXT,
            file_size TEXT,
            mime_type TEXT,
            audio_duration TEXT,
            status TEXT NOT NULL,
            progress REAL NOT NULL DEFAULT 0,
            remote_path TEXT,
            remote_url TEXT,
            error TEXT,
            attempts INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_media_outbox_chat ON media_outbox(chat_id, created_at)');
        await db.execute('CREATE INDEX idx_media_outbox_status ON media_outbox(status, created_at)');
      },
    );
    return _db!;
  }

  Future<void> initialize({bool startBackgroundWorker = true}) async {
    await _database;
    await _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      unawaited(processPending());
      unawaited(_scheduleOneOffWorker());
    });
    if (startBackgroundWorker) await _initializeBackgroundWorker();
    unawaited(processPending());
  }

  Future<void> _initializeBackgroundWorker() async {
    if (_workerInitialized) return;
    try {
      await Workmanager().initialize(chatMediaTransferCallbackDispatcher, isInDebugMode: false);
      _workerInitialized = true;
      await Workmanager().registerPeriodicTask(
        'sehatak-chat-media-periodic',
        chatMediaTransferTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      await _scheduleOneOffWorker();
    } catch (_) {}
  }

  Future<void> _scheduleOneOffWorker() async {
    if (!_workerInitialized) return;
    try {
      await Workmanager().registerOneOffTask(
        'sehatak-chat-media-${DateTime.now().microsecondsSinceEpoch}',
        chatMediaTransferTask,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {}
  }

  Future<String> enqueue({
    required String chatId,
    required File sourceFile,
    required String type,
    required String folder,
    required String preview,
    String? fileName,
    String? fileSize,
    String? mimeType,
    String? audioDuration,
  }) async {
    if (!await sourceFile.exists()) throw StateError('الملف المحلي غير موجود');
    final id = '${chatId}_${DateTime.now().microsecondsSinceEpoch}_${sourceFile.uri.pathSegments.last.hashCode.abs()}';
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'sehatak_chat_media', chatId));
    await mediaDir.create(recursive: true);
    final safeName = (fileName?.trim().isNotEmpty == true ? fileName!.trim() : p.basename(sourceFile.path)).replaceAll(RegExp(r'[/\\]'), '_');
    final local = File(p.join(mediaDir.path, '${id}_$safeName'));
    await sourceFile.copy(local.path);
    final now = DateTime.now().millisecondsSinceEpoch;
    final db = await _database;
    await db.insert('media_outbox', {
      'id': id,
      'chat_id': chatId,
      'local_path': local.path,
      'type': type,
      'folder': folder,
      'preview': preview,
      'file_name': fileName ?? safeName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'audio_duration': audioDuration,
      'status': 'queued',
      'progress': 0,
      'attempts': 0,
      'created_at': now,
      'updated_at': now,
    });
    unawaited(processPending());
    unawaited(_scheduleOneOffWorker());
    return id;
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _database;
    final rows = await db.query('media_outbox', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> pendingForChat(String chatId) async {
    final db = await _database;
    return db.query('media_outbox', where: 'chat_id = ? AND status != ?', whereArgs: [chatId, 'sent'], orderBy: 'created_at ASC');
  }

  Future<void> processPending() async {
    if (_processing) return;
    _processing = true;
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (_isOffline(connectivity)) return;
      final db = await _database;
      final jobs = await db.query('media_outbox', where: 'status != ?', whereArgs: ['sent'], orderBy: 'created_at ASC', limit: 3);
      for (final job in jobs) {
        try {
          await _process(job);
        } catch (e) {
          await db.update('media_outbox', {
            'status': 'retry',
            'error': e.toString(),
            'attempts': (job['attempts'] as int? ?? 0) + 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          }, where: 'id = ?', whereArgs: [job['id']]);
        }
      }
    } finally {
      _processing = false;
    }
  }

  bool _isOffline(dynamic result) {
    if (result is List<ConnectivityResult>) return result.contains(ConnectivityResult.none) && result.length == 1;
    return result == ConnectivityResult.none;
  }

  Future<void> _process(Map<String, dynamic> job) async {
    final db = await _database;
    final id = job['id'].toString();
    final file = File(job['local_path'].toString());
    if (!await file.exists()) throw StateError('النسخة المحلية للملف لم تعد موجودة');
    await db.update('media_outbox', {'status': 'uploading', 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);

    final nextcloud = NextcloudService();
    await nextcloud.loadConfig();
    final upload = await nextcloud.uploadFile(
      file: file,
      path: 'chats/${job['chat_id']}/${job['folder']}',
      fileName: job['file_name']?.toString(),
      onProgress: (sent, total) {
        if (total <= 0) return;
        unawaited(db.update('media_outbox', {'progress': sent / total, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]));
      },
      createShare: true,
    );
    if (!upload.success || upload.path == null) throw StateError(upload.error ?? 'تعذر رفع الوسائط');

    await db.update('media_outbox', {
      'status': 'uploaded',
      'progress': 1,
      'remote_path': upload.path,
      'remote_url': upload.url,
      'error': upload.error,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [id]);

    var url = upload.url;
    if (url == null || url.isEmpty) url = await _retryShare(nextcloud, upload.path!);
    if (url == null || url.isEmpty) throw StateError('تم رفع الملف، لكن رابط المشاركة لم يصبح جاهزًا بعد');
    if (!await nextcloud.verifyPublicUrl(url)) throw StateError('تم إنشاء الرابط لكنه لم يجتز فحص الوصول');

    await db.update('media_outbox', {'status': 'link_ready', 'remote_url': url, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('المستخدم غير مسجل الدخول');
    final type = job['type'].toString();
    await ChatService().sendMessage(
      chatId: job['chat_id'].toString(),
      text: job['preview'].toString(),
      imageUrl: type == 'image' ? url : null,
      videoUrl: type == 'video' ? url : null,
      audioUrl: type == 'audio' ? url : null,
      fileUrl: type == 'file' ? url : null,
      fileName: job['file_name']?.toString(),
      fileSize: job['file_size']?.toString(),
      fileMimeType: job['mime_type']?.toString(),
      audioDuration: job['audio_duration']?.toString(),
      idempotencyKey: 'media_$id',
    );
    await db.update('media_outbox', {'status': 'sent', 'remote_url': url, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
    try { await file.delete(); } catch (_) {}
  }

  Future<String?> _retryShare(NextcloudService service, String remotePath) async {
    for (var i = 0; i < 3; i++) {
      final url = await service.createPublicShare(remotePath);
      if (url != null && url.isNotEmpty) return url;
      await Future<void>.delayed(Duration(seconds: 2 * (i + 1)));
    }
    return null;
  }

  Future<void> retry(String id) async {
    final db = await _database;
    await db.update('media_outbox', {'status': 'queued', 'error': null, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
    await processPending();
    unawaited(_scheduleOneOffWorker());
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await _db?.close();
    _db = null;
  }
}
