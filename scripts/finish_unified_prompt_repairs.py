from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

def patch(path, fn):
    p = ROOT / path
    if not p.exists():
        print('[skip]', path)
        return
    old = p.read_text(encoding='utf-8')
    new = fn(old)
    if new != old:
        p.write_text(new, encoding='utf-8')
        print('[updated]', path)

def add_import(text, needle, imp):
    return text if imp in text else text.replace(needle, needle + '\n' + imp, 1)

def chat_screen(t):
    t = add_import(t, "import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:sehatak/app_router.dart';")
    t = t.replace("onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen())),", "onTap: () => context.push(AppRouter.aiChatbot),")
    t = t.replace("final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddStatusScreen()));", "final created = await context.push<bool>(AppRouter.addStatus);")
    t = re.sub(r"await Navigator\.push\(\s*context,\s*MaterialPageRoute\(builder: \(_\) => StoryViewerScreen\(status: status\)\),\s*\);", "await context.push(AppRouter.storyViewer, extra: status);", t)
    t = re.sub(r"await Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder: \(_\) => ChatRoomScreen\(chatId: chatId, otherUserId: otherId, otherUserName: name, groupImage: image\.isEmpty \? null : image\),\s*\),\s*\);", "await context.push(AppRouter.chatRoom, extra: <String, dynamic>{'chatId': chatId, 'otherUserId': otherId, 'otherUserName': name, 'groupImage': image.isEmpty ? null : image});", t)
    return t
patch('lib/presentation/screens/chat/chat_screen.dart', chat_screen)

def contacts(t):
    t = add_import(t, "import 'package:flutter/material.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:sehatak/app_router.dart';")
    t = t.replace("final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddStatusScreen()));", "final created = await context.push<bool>(AppRouter.addStatus);")
    t = re.sub(r"await Navigator\.push\(context, MaterialPageRoute\(builder: \(_\) => StoryViewerScreen\(status: status\)\)\);", "await context.push(AppRouter.storyViewer, extra: status);", t)
    t = re.sub(r"await Navigator\.push\(context, MaterialPageRoute\(builder: \(_\) => ChatRoomScreen\(chatId: chatId, otherUserId: item\.userId, otherUserName: item\.name, otherUserImage: item\.image\.isEmpty \? null : item\.image, isGroup: false\)\)\);", "await context.push(AppRouter.chatRoom, extra: <String, dynamic>{'chatId': chatId, 'otherUserId': item.userId, 'otherUserName': item.name, 'otherUserImage': item.image.isEmpty ? null : item.image, 'isGroup': false});", t)
    return t
patch('lib/presentation/widgets/health_contacts_section.dart', contacts)

def add_status(t):
    t = add_import(t, "import 'package:flutter/material.dart';", "import 'package:go_router/go_router.dart';")
    return t.replace('Navigator.of(context).pop(true);', 'context.pop(true);')
patch('lib/presentation/screens/chat/add_status_screen.dart', add_status)

def shared_chat(t):
    t = add_import(t, "import 'package:flutter/material.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:sehatak/app_router.dart';")
    old_chat = "Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(\n        chatId: chatId,\n        userName: doctorName.trim().isNotEmpty ? doctorName.trim() : 'الطبيب',\n        userId: doctorId.trim(),\n        isDoctor: false,\n        userImage: doctorImage,\n      )))"
    new_chat = "context.push(AppRouter.chatDetail, extra: <String, dynamic>{'chatId': chatId, 'userName': doctorName.trim().isNotEmpty ? doctorName.trim() : 'الطبيب', 'userId': doctorId.trim(), 'isDoctor': false, 'userImage': doctorImage})"
    t = t.replace(old_chat, new_chat)
    old_call = "await Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(chatId: chatId, doctorName: doctorName, doctorId: doctorId, callId: call.id, isVideo: isVideo, isOutgoing: true)))"
    new_call = "await context.push(AppRouter.call, extra: <String, dynamic>{'chatId': chatId, 'doctorName': doctorName, 'doctorId': doctorId, 'callId': call.id, 'isVideo': isVideo, 'isOutgoing': true})"
    t = t.replace(old_call, new_call)
    return t
patch('lib/presentation/screens/shared/chat_navigation.dart', shared_chat)
