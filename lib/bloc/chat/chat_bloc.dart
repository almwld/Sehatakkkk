// ============================================================
// 💬 ChatBloc - بلوك المحادثات الكامل
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../core/services/chat_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();
  Stream<List<ChatModel>>? _chatStream;
  StreamSubscription<List<ChatModel>>? _subscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<RefreshChats>(_onRefreshChats);
    on<CreateChat>(_onCreateChat);
    on<LoadChat>(_onLoadChat);
    on<DeleteChat>(_onDeleteChat);
    on<PinChat>(_onPinChat);
    on<UnpinChat>(_onUnpinChat);
    on<MuteChat>(_onMuteChat);
    on<UnmuteChat>(_onUnmuteChat);
    on<ArchiveChat>(_onArchiveChat);
    on<UnarchiveChat>(_onUnarchiveChat);
    on<StreamChats>(_onStreamChats);
    on<StopStreamingChats>(_onStopStreamingChats);
  }

  // ============================================================
  // 📥 تحميل المحادثات
  // ============================================================

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await _chatService.getChats();
      emit(ChatLoaded(chats: chats));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 🔄 تحديث المحادثات
  // ============================================================

  Future<void> _onRefreshChats(RefreshChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await _chatService.getChats();
      emit(ChatLoaded(chats: chats));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📝 إنشاء محادثة
  // ============================================================

  Future<void> _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    try {
      final chat = await _chatService.createChat(
        doctorId: event.doctorId,
        doctorName: event.doctorName,
        patientName: event.patientName,
        patientId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
      // جلب المحادثة الكاملة
      final fullChat = await _chatService.getChat(chat);
      if (fullChat != null) {
        emit(ChatCreated(chat: fullChat));
      }
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📋 تحميل محادثة محددة
  // ============================================================

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    try {
      final chat = await _chatService.getChat(event.chatId);
      if (chat != null) {
        emit(ChatDetailLoaded(chat: chat));
      } else {
        emit(ChatError(message: 'المحادثة غير موجودة'));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 🗑️ حذف محادثة
  // ============================================================

  Future<void> _onDeleteChat(DeleteChat event, Emitter<ChatState> emit) async {
    try {
      await _chatService.deleteChat(event.chatId);
      emit(ChatDeleted(chatId: event.chatId));
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📌 تثبيت محادثة
  // ============================================================

  Future<void> _onPinChat(PinChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ تثبيت
      emit(ChatPinned(chatId: event.chatId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📌 إلغاء تثبيت محادثة
  // ============================================================

  Future<void> _onUnpinChat(UnpinChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ إلغاء تثبيت
      emit(ChatUnpinned(chatId: event.chatId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 🔇 كتم محادثة
  // ============================================================

  Future<void> _onMuteChat(MuteChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ كتم
      emit(ChatMuted(chatId: event.chatId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 🔇 إلغاء كتم محادثة
  // ============================================================

  Future<void> _onUnmuteChat(UnmuteChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ إلغاء كتم
      emit(ChatUnmuted(chatId: event.chatId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📦 أرشفة محادثة
  // ============================================================

  Future<void> _onArchiveChat(ArchiveChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ أرشفة
      emit(ChatArchived(chatId: event.chatId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📦 إلغاء أرشفة محادثة
  // ============================================================

  Future<void> _onUnarchiveChat(UnarchiveChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ إلغاء أرشفة
      emit(ChatUnarchived(chatId: event.chatId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📡 البث الفوري للمحادثات
  // ============================================================

  Future<void> _onStreamChats(StreamChats event, Emitter<ChatState> emit) async {
    await _subscription?.cancel();

    _chatStream = _chatService.streamChats();
    _subscription = _chatStream?.listen(
      (chats) {
        if (state is ChatLoaded) {
          final currentState = state as ChatLoaded;
          emit(ChatLoaded(
            chats: chats,
            isStreaming: true,
          ));
        } else {
          emit(ChatLoaded(
            chats: chats,
            isStreaming: true,
          ));
        }
      },
      onError: (error) {
        emit(ChatError(message: error.toString()));
      },
    );
  }

  // ============================================================
  // ⏹️ إيقاف البث الفوري
  // ============================================================

  Future<void> _onStopStreamingChats(
    StopStreamingChats event,
    Emitter<ChatState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(ChatLoaded(
        chats: currentState.chats,
        isStreaming: false,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
