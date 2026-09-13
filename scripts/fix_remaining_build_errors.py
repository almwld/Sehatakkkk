from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

# إصلاح قوس Row في بطاقة الطبيب.
home = ROOT / 'lib/presentation/screens/home/tabs/home_tab.dart'
s = home.read_text(encoding='utf-8')
s = s.replace("Text('${doctor['rating'] ?? 0}', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted))]]),", "Text('${doctor['rating'] ?? 0}', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted))]),")
home.write_text(s, encoding='utf-8')

# المؤشرات الحيوية أصبحت تعتمد على LiveVitalsGrid، لذلك لا يجوز أن تبقى الدالة
# القديمة مرتبطة بـ _healthMetrics المحذوفة.
health = ROOT / 'lib/presentation/screens/health/health_dashboard.dart'
s = health.read_text(encoding='utf-8')
if "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';" not in s:
    s = s.replace(
        "import 'package:sehatak/core/constants/app_colors.dart';",
        "import 'package:sehatak/core/constants/app_colors.dart';\nimport 'package:sehatak/presentation/widgets/live_vitals_grid.dart';",
        1,
    )
start = s.find('  Widget _buildMetricsGrid(bool isDark) {')
if start >= 0:
    brace = s.find('{', start)
    depth = 0
    end = None
    for i in range(brace, len(s)):
        if s[i] == '{':
            depth += 1
        elif s[i] == '}':
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end is not None:
        replacement = "  Widget _buildMetricsGrid(bool isDark) {\n    return LiveVitalsGrid(\n      keys: const ['heartRate', 'bloodPressure', 'glucose', 'weight'],\n    );\n  }"
        s = s[:start] + replacement + s[end:]
health.write_text(s, encoding='utf-8')

print('[fixed] remaining build errors')
