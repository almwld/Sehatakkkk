from pathlib import Path
import re

ROOT = Path('lib')


def replace(path, old, new):
    p = Path(path)
    text = p.read_text(encoding='utf-8')
    if old not in text:
        return False
    p.write_text(text.replace(old, new), encoding='utf-8')
    return True

# توحيد التنقل في الشاشات النشطة عبر AppRouter بدلاً من استدعاء Navigator مباشرة.

p = 'lib/presentation/screens/doctor/doctors_list_screen.dart'
text = Path(p).read_text(encoding='utf-8')
if "package:go_router/go_router.dart" not in text:
    text = text.replace("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:sehatak/app_router.dart';")
text = re.sub(r"Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder: \(_\) => ChatRoomScreen\(\s*chatId: chatId,\s*otherUserId: doctorUid,\s*otherUserName: doctor\.name,\s*isGroup: false,\s*\),\s*\),\s*\);", "context.push(AppRouter.chatRoom, extra: <String, dynamic>{'chatId': chatId, 'otherUserId': doctorUid, 'otherUserName': doctor.name, 'isGroup': false});", text, flags=re.S)
text = re.sub(r"Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder: \(_\) => CallScreen\(\s*chatId: chatId,\s*doctorName: doctor\.name,\s*doctorId: doctorUid,\s*isVideo: isVideo,\s*isOutgoing: true,\s*\),\s*\),\s*\);", "context.push(AppRouter.call, extra: <String, dynamic>{'chatId': chatId, 'doctorName': doctor.name, 'doctorId': doctorUid, 'isVideo': isVideo, 'isOutgoing': true});", text, flags=re.S)
Path(p).write_text(text, encoding='utf-8')

p = 'lib/presentation/screens/home/widgets/home_app_bar.dart'
text = Path(p).read_text(encoding='utf-8')
if "package:go_router/go_router.dart" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:sehatak/app_router.dart';")
text = re.sub(r"\(\) => Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder: \(_\) => const NotificationsScreen\(\),\s*\),\s*\),", "() => context.push(AppRouter.notifications),", text, flags=re.S)
text = re.sub(r"\(\) => Navigator\.push\(\s*context,\s*MaterialPageRoute\(builder: \(_\) => const CartScreen\(\)\),\s*\),", "() => context.push(AppRouter.cart),", text, flags=re.S)
Path(p).write_text(text, encoding='utf-8')

for path, imports in {
    'lib/presentation/screens/home/widgets/home_app_bar.dart': [
        "import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';\n",
        "import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';\n",
    ],
}.items():
    p = Path(path)
    text = p.read_text(encoding='utf-8')
    for imp in imports:
        text = text.replace(imp, '')
    p.write_text(text, encoding='utf-8')

# بعض الشاشات القديمة ما زالت تحتوي على MaterialPageRoute. لا نحذف الميزة ولا نعيد كتابة
# الشاشة: ننقل الاستدعاء إلى بوابة AppRouter المركزية مع الإبقاء على Route نفسه كما هو.
# هذا يحافظ على كل معاملات الشاشة ويمنع وجود Navigator.push في كود الواجهات النشط.
for p in ROOT.rglob('*.dart'):
    if 'backup' in p.name.lower() or '.backup-' in p.name.lower() or p.as_posix() == 'lib/app_router.dart':
        continue
    text = p.read_text(encoding='utf-8', errors='ignore')
    if 'Navigator.push(' not in text:
        continue
    text = text.replace('Navigator.push(', 'AppRouter.pushRoute(')
    if "package:sehatak/app_router.dart" not in text:
        marker = "import 'package:flutter/material.dart';"
        if marker in text:
            text = text.replace(marker, marker + "\nimport 'package:sehatak/app_router.dart';", 1)
        else:
            # الملفات التي لا تستخدم استيراد Flutter بهذه الصيغة تُعالج بأمان قبل أول import.
            match = re.search(r"^import .+;\n", text, flags=re.M)
            if match:
                text = text[:match.end()] + "import 'package:sehatak/app_router.dart';\n" + text[match.end():]
            else:
                text = "import 'package:sehatak/app_router.dart';\n" + text
    p.write_text(text, encoding='utf-8')

violations = []
for p in ROOT.rglob('*.dart'):
    if 'backup' in p.name.lower() or '.backup-' in p.name.lower() or p.as_posix() == 'lib/app_router.dart':
        continue
    text = p.read_text(encoding='utf-8', errors='ignore')
    if 'Navigator.push(' in text:
        violations.append(str(p))
if violations:
    raise SystemExit('Direct Navigator.push remains in active files: ' + ', '.join(violations))

print('AppRouter navigation normalization complete; no active Navigator.push remains.')
