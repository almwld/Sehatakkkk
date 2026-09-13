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
    # زيادة زر بدء محادثة الدردشة بنسبة 4% مع الحفاظ على تصميمه ووظيفته.
    t = t.replace("FloatingActionButton.extended(\n              backgroundColor: AppColors.primary,", "FloatingActionButton.extended(\n              extendedPadding: const EdgeInsets.symmetric(horizontal: 17),\n              backgroundColor: AppColors.primary,")
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

def chat_service_indexes(t):
    t = t.replace(".where('senderId',isNotEqualTo:id).where('isDelivered',isEqualTo:false).limit(100).get()", ".where('senderId',isNotEqualTo:id).limit(100).get()")
    t = t.replace("final b=_firestore.batch();for(final d in s.docs)b.update(d.reference,{'isDelivered':true,'deliveredAt':FieldValue.serverTimestamp()});await b.commit();", "final b=_firestore.batch();for(final d in s.docs){if(d.data()['isDelivered']==true)continue;b.update(d.reference,{'isDelivered':true,'deliveredAt':FieldValue.serverTimestamp()});}await b.commit();")
    t = t.replace(".where('senderId',isNotEqualTo:id).where('isRead',isEqualTo:false).limit(100).get()", ".where('senderId',isNotEqualTo:id).limit(100).get()")
    t = t.replace("final b=_firestore.batch();for(final d in s.docs)b.update(d.reference,{'isDelivered':true,'deliveredAt':d.data()['deliveredAt']??FieldValue.serverTimestamp(),'isRead':true,'readAt':FieldValue.serverTimestamp()});b.update(_chatRef(chatId),{'unreadCount.$id':0});await b.commit();", "final b=_firestore.batch();for(final d in s.docs){if(d.data()['isRead']==true)continue;b.update(d.reference,{'isDelivered':true,'deliveredAt':d.data()['deliveredAt']??FieldValue.serverTimestamp(),'isRead':true,'readAt':FieldValue.serverTimestamp()});}b.update(_chatRef(chatId),{'unreadCount.$id':0});await b.commit();")
    return t
patch('lib/core/services/chat_service.dart', chat_service_indexes)

def health_dashboard(t):
    t = re.sub(r"\n  // ✅ المؤشرات الصحية - أيقونات مكبرة بدون حاويات\n  final List<Map<String, dynamic>> _healthMetrics = \[.*?\n  \];\n", "\n", t, count=1, flags=re.S)
    t = t.replace("_healthScore = 78.5;", "_healthScore = 0.0;")
    return t
patch('lib/presentation/screens/health/health_dashboard.dart', health_dashboard)

def home_order(t):
    # ترتيب الصفحة الرئيسية حسب المواصفة: المؤشرات قبل الخدمات، والطقس ضمن المحتوى الحقيقي قبل المجتمع.
    old = """                SliverToBoxAdapter(child: KeyedSubtree(key: _quickServicesTourKey, child: _quickServices(dark))),
                SliverToBoxAdapter(child: KeyedSubtree(key: _vitalsTourKey, child: _healthSummary(state, dark))),"""
    new = """                SliverToBoxAdapter(child: KeyedSubtree(key: _vitalsTourKey, child: _healthSummary(state, dark))),
                SliverToBoxAdapter(child: KeyedSubtree(key: _quickServicesTourKey, child: _quickServices(dark))),"""
    t = t.replace(old, new, 1)
    old2 = """                SliverToBoxAdapter(child: _articles(state.articles, dark)),
                SliverToBoxAdapter(child: _tips(state.tips, dark)),
                SliverToBoxAdapter(child: _discover(dark)),
                SliverToBoxAdapter(child: _weather(dark)),
                SliverToBoxAdapter(child: KeyedSubtree(key: _communityTourKey, child: _community(state.communityPosts, dark))),"""
    new2 = """                SliverToBoxAdapter(child: _articles(state.articles, dark)),
                SliverToBoxAdapter(child: _tips(state.tips, dark)),
                SliverToBoxAdapter(child: _weather(dark)),
                SliverToBoxAdapter(child: _discover(dark)),
                SliverToBoxAdapter(child: KeyedSubtree(key: _communityTourKey, child: _community(state.communityPosts, dark))),"""
    t = t.replace(old2, new2, 1)
    return t
patch('lib/presentation/screens/home/tabs/home_tab.dart', home_order)
