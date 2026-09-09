from pathlib import Path
import re

path = Path('lib/presentation/screens/auth/auth_screen.dart')
s = path.read_text(encoding='utf-8')

if 'Text(\n                    _getGreetingSubtitle(),' not in s:
    pattern = re.compile(r"(Text\(\s*isSignUp\s*\? 'إنشاء حساب جديد'\s*:\s*_getGreetingTitle\(\),.*?\n\s*\),\n\s*const SizedBox\(height: 8\),)", re.S)
    m = pattern.search(s)
    if not m:
        raise SystemExit('Greeting widget anchor not found')
    block = m.group(1)
    replacement = block.replace(
        'const SizedBox(height: 8),',
        "const SizedBox(height: 8),\n                if (!isSignUp)\n                  Text(\n                    _getGreetingSubtitle(),\n                    style: TextStyle(\n                      fontSize: 14,\n                      color: isDark ? Colors.white70 : Colors.grey[600],\n                      fontFamily: 'NotoSansArabicUI',\n                    ),\n                    textAlign: TextAlign.center,\n                  ),\n                const SizedBox(height: 12),",
        1,
    )
    s = s[:m.start(1)] + replacement + s[m.end(1):]
    path.write_text(s, encoding='utf-8')
    print('Greeting subtitle added.')
else:
    print('Greeting subtitle already present.')
