// ============================================================
// 💬 ChatBloc - بلوك المحادثات
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
    on<CreateChat>(_onCreateChat);
    on<LoadChat>(_onLoadChat);
    on<DeleteChat>(_onDeleteChat);
    on<StreamChats>(_onStreamChats);
    on<StopStreamingChats>(_onStopStreamingChats);
    on<TogglePinChat>(_onTogglePinChat);
    on<ToggleMuteChat>(_onToggleMuteChat);
    on<ArchiveChat>(_onArchiveChat);
    on<UnarchiveChat>(_onUnarchiveChat);
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
  // 📝 إنشاء محادثة
  // ============================================================

  Future<void> _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    try {
      final chat = await _chatService.createChat(
        doctorId: event.doctorId,
        doctorName: event.doctorName,
        patientName: event.patientName,
        doctorImage: event.doctorImage,
        patientImage: event.patientImage,
      );
      emit(ChatCreated(chat: chat));
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
      emit(ChatDetailLoaded(chat: chat));
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

  // ============================================================
  // 📌 تحديث حالة التثبيت
  // ============================================================

  Future<void> _onTogglePinChat(TogglePinChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ تحديث حالة التثبيت
      emit(ChatPinned(chatId: event.chatId, isPinned: event.isPinned));
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 🔇 تحديث حالة الكتم
  // ============================================================

  Future<void> _onToggleMuteChat(ToggleMuteChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ تحديث حالة الكتم
      emit(ChatMuted(chatId: event.chatId, isMuted: event.isMuted));
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📦 أرشفة محادثة
  // ============================================================

  Future<void> _onArchiveChat(ArchiveChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ أرشفة المحادثة
      emit(ChatArchived(chatId: event.chatId));
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // ============================================================
  // 📦 إلغاء أرشفة محادثة
  // ============================================================

  Future<void> _onUnarchiveChat(UnarchiveChat event, Emitter<ChatState> emit) async {
    try {
      // TODO: تنفيذ إلغاء أرشفة المحادثة
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
