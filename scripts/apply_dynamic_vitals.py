from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def add_import(path, import_line):
    p = ROOT / path
    s = p.read_text()
    if import_line not in s:
        marker = "import 'package:sehatak/core/constants/app_colors.dart';"
        if marker in s:
            s = s.replace(marker, marker + "\n" + import_line, 1)
        else:
            s = import_line + "\n" + s
        p.write_text(s)


def replace_grid(path, marker, replacement):
    p = ROOT / path
    s = p.read_text()
    pos = s.find(marker)
    if pos < 0:
        return False
    start = s.rfind('GridView.builder(', 0, pos)
    if start < 0:
        return False
    depth = 0
    in_string = None
    escape = False
    i = start
    while i < len(s):
        ch = s[i]
        if in_string:
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == in_string:
                in_string = None
        else:
            if ch in "'\"":
                in_string = ch
            elif ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
                if depth == 0:
                    end = i + 1
                    s = s[:start] + replacement + s[end:]
                    p.write_text(s)
                    return True
        i += 1
    return False


# صحتي
health = 'lib/presentation/screens/health/health_dashboard.dart'
add_import(health, "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';")
replace_grid(
    health,
    '_buildMetricsGrid(isDark)',
    "LiveVitalsGrid(keys: const ['heartRate', 'bloodPressure', 'glucose', 'weight'])",
)

# شاشة المؤشرات الحيوية
vitals = 'lib/presentation/screens/vitals/vitals_dashboard_screen.dart'
add_import(vitals, "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';")
replace_grid(
    vitals,
    'itemCount: _vitalCards.length',
    "LiveVitalsGrid(keys: const ['bloodPressure', 'glucose', 'heartRate', 'weight', 'bloodOxygen', 'temperature'])",
)

# المزيد
more = 'lib/presentation/screens/more/more_screen.dart'
add_import(more, "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';")
replace_grid(
    more,
    'itemCount: _vitals.length',
    "LiveVitalsGrid(keys: const ['bloodPressure', 'glucose', 'heartRate', 'weight', 'bloodOxygen', 'temperature'], compact: true)",
)

# تسجيل قراءات الضغط في المصدر الموحد.
bp = ROOT / 'lib/presentation/screens/blood_pressure/blood_pressure_screen.dart'
s = bp.read_text()
add_import('lib/presentation/screens/blood_pressure/blood_pressure_screen.dart', "import 'package:sehatak/core/services/vitals_service.dart';")
s = bp.read_text()
old = "    if (_systolicCtrl.text.isEmpty || _diastolicCtrl.text.isEmpty) return;\n\n    setState(() {"
new = "    if (_systolicCtrl.text.isEmpty || _diastolicCtrl.text.isEmpty) return;\n    final systolic = int.parse(_systolicCtrl.text);\n    final diastolic = int.parse(_diastolicCtrl.text);\n\n    setState(() {"
if old in s and "VitalsService.instance.record('bloodPressure'" not in s:
    s = s.replace(old, new, 1)
    needle = "      _pulseCtrl.clear();\n    });"
    s = s.replace(needle, needle + "\n    VitalsService.instance.record('bloodPressure', '$systolic/$diastolic');", 1)
    bp.write_text(s)

# تسجيل قراءات السكر.
gl = ROOT / 'lib/presentation/screens/glucose_tracker/glucose_tracker_screen.dart'
add_import('lib/presentation/screens/glucose_tracker/glucose_tracker_screen.dart', "import 'package:sehatak/core/services/vitals_service.dart';")
s = gl.read_text()
old = "    if (_glucoseCtrl.text.isEmpty) return;\n\n    setState(() {"
new = "    if (_glucoseCtrl.text.isEmpty) return;\n    final glucose = int.parse(_glucoseCtrl.text);\n\n    setState(() {"
if old in s and "VitalsService.instance.record('glucose'" not in s:
    s = s.replace(old, new, 1)
    needle = "      _glucoseCtrl.clear();\n    });"
    s = s.replace(needle, needle + "\n    VitalsService.instance.record('glucose', glucose, extra: {'meal': _selectedMeal});", 1)
    gl.write_text(s)

# تسجيل الوزن في Firestore مع الإبقاء على التخزين المحلي.
wt = ROOT / 'lib/presentation/screens/weight_tracker/weight_tracker_screen.dart'
add_import('lib/presentation/screens/weight_tracker/weight_tracker_screen.dart', "import 'package:sehatak/core/services/vitals_service.dart';")
s = wt.read_text()
needle = "    _saveWeightData();\n    ToastService.showSuccess('✅ تم تسجيل الوزن: $weight كجم');"
if needle in s and "VitalsService.instance.record('weight'" not in s:
    s = s.replace(needle, "    _saveWeightData();\n    VitalsService.instance.record('weight', weight);\n    ToastService.showSuccess('✅ تم تسجيل الوزن: $weight كجم');", 1)
    wt.write_text(s)

# نبض القلب: الاحتفاظ بالتخزين المحلي وإضافة نسخة موحدة للمؤشر الحالي.
hr = ROOT / 'lib/services/heart_rate_service.dart'
s = hr.read_text()
import_line = "import 'package:sehatak/core/services/vitals_service.dart';"
if import_line not in s:
    s = s.replace("import 'package:path/path.dart';", "import 'package:path/path.dart';\n" + import_line, 1)
needle = "      await db.insert('heart_rate_measurements', {"
# لا نعيد بناء دالة الحفظ؛ نسجل القيمة بعد نجاح قاعدة البيانات.
end_marker = "      });\n    } catch (e) {\n      debugPrint('HeartRate save error: $e');"
if import_line in s and "VitalsService.instance.record('heartRate'" not in s and end_marker in s:
    s = s.replace(end_marker, "      });\n      await VitalsService.instance.record('heartRate', _currentBPM);\n    } catch (e) {\n      debugPrint('HeartRate save error: $e');", 1)
hr.write_text(s)

print('Dynamic vitals patch applied.')
