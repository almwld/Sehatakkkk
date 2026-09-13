from pathlib import Path

path = Path('lib/presentation/screens/dashboard/role_based_dashboard_screen.dart')
text = path.read_text(encoding='utf-8')

imp = "import 'package:sehatak/presentation/screens/dashboard/role_dashboard_specs.dart';\n"
if imp not in text:
    anchor = "import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';\n"
    text = text.replace(anchor, anchor + imp)

text = text.replace(
    "    final name = AppRoles.getRoleName(widget.role);\n    final actions = _actionsFor(widget.role);",
    "    final spec = RoleDashboardSpecs.forRole(widget.role);\n    final name = spec.title;\n    final actions = spec.actions;",
)
text = text.replace(
    "      Text('لوحة $roleName المهنية — بيانات الحساب الفعلية', style: const TextStyle(color: Colors.white70, fontSize: 12)),",
    "      Text(RoleDashboardSpecs.forRole(widget.role).subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),",
)
text = text.replace(
    "            const Text('إدارة الحساب والخدمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),",
    "            Text('إدارة ${RoleDashboardSpecs.forRole(widget.role).title} وخدماتها', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),",
)

# استبدال دالة الإجراءات القديمة بدالة تحويل الإعدادات إلى بطاقات العرض.
start = text.find('  List<_DashboardAction> _actionsFor(String role) {')
if start != -1:
    depth = 0
    end = None
    in_string = False
    escape = False
    for i in range(start, len(text)):
        ch = text[i]
        if in_string:
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == "'":
                in_string = False
            continue
        if ch == "'":
            in_string = True
            continue
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end is None:
        raise SystemExit('Could not locate _actionsFor body')
    replacement = '''  List<_DashboardAction> _actionsFor(String role) {\n    return RoleDashboardSpecs.forRole(role).actions\n        .map((item) => _DashboardAction(item.title, item.subtitle, item.route, item.icon))\n        .toList(growable: false);\n  }'''
    text = text[:start] + replacement + text[end:]

path.write_text(text, encoding='utf-8')
print('Applied independent role dashboard specifications.')
