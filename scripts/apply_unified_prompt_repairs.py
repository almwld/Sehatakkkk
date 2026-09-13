from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def edit(path, replacements):
    p = ROOT / path
    if not p.exists():
        print(f'[skip] missing {path}')
        return
    text = p.read_text(encoding='utf-8')
    original = text
    for old, new in replacements:
        if old in text:
            text = text.replace(old, new, 1)
        else:
            print(f'[skip] pattern not found: {path}')
    if text != original:
        p.write_text(text, encoding='utf-8')
        print(f'[updated] {path}')

# الرسائل: تسجيل الوصول قبل القراءة حتى تتزامن ✓✓ مع الطرف المرسل.
chat_service = ROOT / 'lib/core/services/chat_service.dart'
if chat_service.exists():
    text = chat_service.read_text(encoding='utf-8')
    marker = 'Future<void> markAsDelivered(String chatId)'
    # اجعل الإصلاح idempotent: لا نضيف الدالة مرة أخرى إذا كانت موجودة بالفعل.
    if marker not in text:
        needle = '  Future<void> archiveChat(String chatId,bool archived){'
        method = "  /// يسجل وصول الرسائل للطرف الآخر فور استقبالها وقبل فتح الغرفة.\n  Future<void> markAsDelivered(String chatId)async{final id=_uid();await _authorizedChat(chatId);final s=await _chatRef(chatId).collection('messages').where('senderId',isNotEqualTo:id).where('isDelivered',isEqualTo:false).limit(100).get();if(s.docs.isEmpty)return;final b=_firestore.batch();for(final d in s.docs)b.update(d.reference,{'isDelivered':true,'deliveredAt':FieldValue.serverTimestamp()});await b.commit();}\n"
        if needle in text:
            chat_service.write_text(text.replace(needle, method + needle, 1), encoding='utf-8')
            print('[updated] chat_service delivered-message support')
    else:
        print('[ok] chat_service markAsDelivered already present; no duplicate injection')

edit('lib/presentation/screens/chat/chat_detail_screen.dart', [(
    "      await _chatService.markAsRead(widget.chatId);",
    "      await _chatService.markAsDelivered(widget.chatId);\n      await _chatService.markAsRead(widget.chatId);"
)])

# منع التنقل المباشر من HomeTab.
edit('lib/presentation/screens/home/tabs/home_tab.dart', [(
    "  Widget _quickServices(bool dark) => QuickServicesWidget(isDark: dark, onNavigate: (screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)));",
    "  Widget _quickServices(bool dark) => QuickServicesWidget(isDark: dark, onNavigate: (screen) { if (!mounted) return; _go(AppRouter.services); });"
)])

# توحيد أيقونة الصيدلية في لوحة المريض.
p = ROOT / 'lib/presentation/screens/patient/patient_dashboard.dart'
if p.exists():
    text = p.read_text(encoding='utf-8')
    updated = text.replace('assets/images/services/pharmacy.png', 'assets/images/services/medications.png')
    if updated != text:
        p.write_text(updated, encoding='utf-8')
        print('[updated] patient dashboard pharmacy icon')

# المسارات الرسمية للجولات؛ التنفيذ الحالي يبقى المصدر الوحيد ولا يتم حذف أي كود.
exports = {
    'lib/core/tour/tour_models.dart': "export '../../presentation/widgets/home/guided_tour/tour_models.dart';\n",
    'lib/core/tour/tour_themes.dart': "export '../../presentation/widgets/home/guided_tour/tour_themes.dart';\n",
    'lib/core/tour/tour_manager.dart': "export '../../presentation/widgets/home/guided_tour/tour_manager.dart';\n",
    'lib/core/tour/tour_pulse.dart': "export '../../presentation/widgets/home/guided_tour/tour_pulse.dart';\n",
    'lib/core/tour/tour_spotlight.dart': "export '../../presentation/widgets/home/guided_tour/tour_spotlight.dart';\n",
    'lib/core/tour/tour_guided.dart': "export '../../presentation/widgets/home/guided_tour/tour_guided.dart';\n",
    'lib/features/tours/home_tour.dart': "export '../../presentation/widgets/home/guided_tour/home_tour.dart';\n",
    'lib/features/tours/doctors_tour.dart': "export '../../presentation/widgets/home/guided_tour/doctors_tour.dart';\n",
    'lib/features/tours/pharmacy_tour.dart': "export '../../presentation/widgets/home/guided_tour/pharmacy_tour.dart';\n",
    'lib/features/tours/labs_tour.dart': "export '../../presentation/widgets/home/guided_tour/labs_tour.dart';\n",
    'lib/features/tours/profile_tour.dart': "export '../../presentation/widgets/home/guided_tour/profile_tour.dart';\n",
    'lib/features/tours/more_tour.dart': "export '../../presentation/widgets/home/guided_tour/more_tour.dart';\n",
}
for rel, content in exports.items():
    p = ROOT / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    if not p.exists():
        p.write_text(content, encoding='utf-8')
        print(f'[created] {rel}')
