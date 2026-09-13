from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def imp(path, line):
    p = ROOT / path; s = p.read_text()
    if line not in s:
        s = s.replace("import 'package:sehatak/core/constants/app_colors.dart';", "import 'package:sehatak/core/constants/app_colors.dart';\n" + line, 1)
        p.write_text(s)

def grid(path, marker, replacement):
    p = ROOT / path; s = p.read_text(); pos = s.find(marker)
    if pos < 0: return
    start = s.rfind('GridView.builder(', 0, pos)
    if start < 0: return
    depth = 0; quote = None; esc = False
    for i in range(start, len(s)):
        c = s[i]
        if quote:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == quote: quote = None
        else:
            if c in "'\"": quote = c
            elif c == '(': depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    p.write_text(s[:start] + replacement + s[i+1:]); return

health='lib/presentation/screens/health/health_dashboard.dart'
imp(health, "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';")
p=ROOT/health; s=p.read_text(); s=s.replace('_buildMetricsGrid(isDark)', "LiveVitalsGrid(keys: const ['heartRate','bloodPressure','glucose','weight'])", 1); p.write_text(s)

vitals='lib/presentation/screens/vitals/vitals_dashboard_screen.dart'
imp(vitals, "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';")
grid(vitals, 'itemCount: _vitalCards.length', "LiveVitalsGrid(keys: const ['bloodPressure','glucose','heartRate','weight','bloodOxygen','temperature'])")

more='lib/presentation/screens/more/more_screen.dart'
imp(more, "import 'package:sehatak/presentation/widgets/live_vitals_grid.dart';")
grid(more, 'itemCount: _vitals.length', "LiveVitalsGrid(keys: const ['bloodPressure','glucose','heartRate','weight','bloodOxygen','temperature'], compact: true)")

bp=ROOT/'lib/presentation/screens/blood_pressure/blood_pressure_screen.dart'; imp('lib/presentation/screens/blood_pressure/blood_pressure_screen.dart', "import 'package:sehatak/core/services/vitals_service.dart';"); s=bp.read_text()
if "VitalsService.instance.record('bloodPressure'" not in s:
    s=s.replace("    if (_systolicCtrl.text.isEmpty || _diastolicCtrl.text.isEmpty) return;", "    if (_systolicCtrl.text.isEmpty || _diastolicCtrl.text.isEmpty) return;\n    final systolic = int.parse(_systolicCtrl.text);\n    final diastolic = int.parse(_diastolicCtrl.text);", 1)
    s=s.replace("      _pulseCtrl.clear();\n    });", "      _pulseCtrl.clear();\n    });\n    VitalsService.instance.record('bloodPressure', '$systolic/$diastolic');", 1); bp.write_text(s)

gl=ROOT/'lib/presentation/screens/glucose_tracker/glucose_tracker_screen.dart'; imp('lib/presentation/screens/glucose_tracker/glucose_tracker_screen.dart', "import 'package:sehatak/core/services/vitals_service.dart';"); s=gl.read_text()
if "VitalsService.instance.record('glucose'" not in s:
    s=s.replace("    if (_glucoseCtrl.text.isEmpty) return;", "    if (_glucoseCtrl.text.isEmpty) return;\n    final glucose = int.parse(_glucoseCtrl.text);", 1)
    s=s.replace("      _glucoseCtrl.clear();\n    });", "      _glucoseCtrl.clear();\n    });\n    VitalsService.instance.record('glucose', glucose, extra: {'meal': _selectedMeal});", 1); gl.write_text(s)

wt=ROOT/'lib/presentation/screens/weight_tracker/weight_tracker_screen.dart'; imp('lib/presentation/screens/weight_tracker/weight_tracker_screen.dart', "import 'package:sehatak/core/services/vitals_service.dart';"); s=wt.read_text()
if "VitalsService.instance.record('weight'" not in s:
    s=s.replace("    _saveWeightData();\n    ToastService.showSuccess('✅ تم تسجيل الوزن: $weight كجم');", "    _saveWeightData();\n    VitalsService.instance.record('weight', weight);\n    ToastService.showSuccess('✅ تم تسجيل الوزن: $weight كجم');", 1); wt.write_text(s)

hr=ROOT/'lib/services/heart_rate_service.dart'; s=hr.read_text(); line="import 'package:sehatak/core/services/vitals_service.dart';"
if line not in s: s=s.replace("import 'package:path/path.dart';", "import 'package:path/path.dart';\n"+line, 1)
if "VitalsService.instance.record('heartRate'" not in s: s=s.replace("      });\n    } catch (e) {\n      debugPrint('HeartRate save error: $e');", "      });\n      await VitalsService.instance.record('heartRate', _currentBPM);\n    } catch (e) {\n      debugPrint('HeartRate save error: $e');", 1); hr.write_text(s)
