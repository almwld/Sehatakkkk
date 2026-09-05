// 🔧 التغييرات المطلوبة في chat_room_screen.dart - الجزء 1

// 1️⃣ إضافة import لشاشة المكالمات في أعلى الملف
import 'package:sehatak/presentation/screens/call/call_screen.dart';

// 2️⃣ تحديث دالة _startCall
void _startCall(bool isVideo) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CallScreen(
        chatId: widget.chatId,
        doctorName: widget.otherUserName,
        doctorId: widget.otherUserId,
        isVideo: isVideo,
      ),
    ),
  );
}
