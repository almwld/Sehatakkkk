#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re

# قائمة الملفات التي تحتاج إصلاح
FILES_TO_FIX = [
    "lib/presentation/screens/more/more_screen.dart",
    "lib/presentation/screens/chat/chat_screen.dart",
    "lib/presentation/screens/wallet/wallet_screen.dart",
    "lib/presentation/screens/subscriptions/subscriptions_screen.dart",
    "lib/presentation/screens/settings/settings_screen.dart",
]

def add_import(file_path):
    """إضافة import ImageService إذا لم يكن موجوداً"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # التحقق من وجود import
    if 'import \'package:sehatak/core/services/image_service.dart\'' in content:
        return content
    
    # البحث عن آخر import وإضافة بعده
    lines = content.split('\n')
    new_lines = []
    import_added = False
    
    for line in lines:
        new_lines.append(line)
        if not import_added and line.startswith('import ') and not line.startswith('import \'package:sehatak'):
            # بعد آخر import
            if 'image_service' not in line:
                new_lines.append("import 'package:sehatak/core/services/image_service.dart';")
                import_added = True
    
    if not import_added:
        # إذا لم يتم العثور على import، أضف في البداية
        new_lines.insert(0, "import 'package:sehatak/core/services/image_service.dart';")
    
    return '\n'.join(new_lines)

def fix_more_screen(content):
    """إصلاح more_screen.dart"""
    # استبدال Icons.* في الخدمات
    replacements = [
        (r"Icons\.medical_services", "ImageService.coreIcon('doctor')"),
        (r"Icons\.local_pharmacy", "ImageService.coreIcon('pharmacy')"),
        (r"Icons\.science", "ImageService.specialtyIcon('radiology')"),
        (r"Icons\.emergency", "ImageService.coreIcon('emergency')"),
        (r"Icons\.chat", "ImageService.navIcon('chat')"),
        (r"Icons\.favorite", "ImageService.coreIcon('health_record')"),
        (r"Icons\.calendar_month", "ImageService.coreIcon('appointments')"),
        (r"Icons\.map", "ImageService.navIcon('home')"),
        (r"Icons\.shield", "ImageService.socialIcon('whatsapp')"),
        (r"Icons\.bloodtype", "ImageService.miniSpecialtyIcon('blood')"),
        (r"Icons\.chat_rounded", "ImageService.navIcon('chat')"),
        (r"Icons\.wallet", "ImageService.coreIcon('pharmacy')"),
        (r"Icons\.subscriptions", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.home_work", "ImageService.coreIcon('home')"),
        (r"Icons\.person", "ImageService.coreIcon('doctor')"),
        (r"Icons\.settings", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.notifications", "ImageService.coreIcon('notifications_active')"),
        (r"Icons\.privacy_tip", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.assignment", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.info", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.help", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.contact_support", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.share", "ImageService.socialIcon('whatsapp')"),
        (r"Icons\.star", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.report", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.download", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.text_fields", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.grid_view", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.woman", "ImageService.miniSpecialtyIcon('baby')"),
        (r"Icons\.child_care", "ImageService.miniSpecialtyIcon('baby')"),
        (r"Icons\.house_rounded", "ImageService.coreIcon('home')"),
        (r"Icons\.pregnant_woman", "ImageService.miniSpecialtyIcon('baby')"),
        (r"Icons\.health_and_safety", "ImageService.coreIcon('home')"),
        (r"Icons\.restaurant", "ImageService.miniSpecialtyIcon('stomach')"),
        (r"Icons\.nightlight", "ImageService.miniSpecialtyIcon('brain')"),
        (r"Icons\.monitor_heart", "ImageService.miniSpecialtyIcon('heart')"),
        (r"Icons\.biotech", "ImageService.miniSpecialtyIcon('dna')"),
        (r"Icons\.monitor_weight", "ImageService.miniSpecialtyIcon('pill')"),
        (r"Icons\.medication", "ImageService.miniSpecialtyIcon('pill')"),
        (r"Icons\.local_hospital", "ImageService.coreIcon('doctor')"),
        (r"Icons\.delivery_dining", "ImageService.coreIcon('pharmacy')"),
        (r"Icons\.history", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.directions_walk", "ImageService.miniSpecialtyIcon('bone')"),
        (r"Icons\.water_drop", "ImageService.miniSpecialtyIcon('blood')"),
        (r"Icons\.fitness_center", "ImageService.miniSpecialtyIcon('bone')"),
        (r"Icons\.healing", "ImageService.miniSpecialtyIcon('heart')"),
    ]
    
    for old, new in replacements:
        content = re.sub(old, new, content)
    
    # إصلاح الدوال التي تستخدم Icon مباشرة
    content = re.sub(r'Icon\(([^,]+),', r'ImageService.svgIcon(\1,', content)
    
    return content

def fix_chat_screen(content):
    """إصلاح chat_screen.dart"""
    replacements = [
        (r"Icons\.chat", "ImageService.navIcon('chat')"),
        (r"Icons\.search", "ImageService.coreIcon('home')"),
        (r"Icons\.more_vert", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.lock_outline", "ImageService.coreIcon('home')"),
        (r"Icons\.login", "ImageService.coreIcon('home')"),
        (r"Icons\.close", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.person", "ImageService.coreIcon('doctor')"),
        (r"Icons\.circle", "ImageService.coreIcon('home')"),
        (r"Icons\.favorite", "ImageService.coreIcon('health_record')"),
        (r"Icons\.chat_bubble_outline", "ImageService.navIcon('chat')"),
        (r"Icons\.repeat", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.bookmark", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.bookmark_border", "ImageService.coreIcon('more_menu')"),
    ]
    
    for old, new in replacements:
        content = re.sub(old, new, content)
    
    return content

def fix_wallet_screen(content):
    """إصلاح wallet_screen.dart"""
    replacements = [
        (r"Icons\.wallet", "ImageService.coreIcon('pharmacy')"),
        (r"Icons\.add", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.attach_money", "ImageService.coreIcon('pharmacy')"),
        (r"Icons\.phone", "ImageService.coreIcon('home')"),
        (r"Icons\.info", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.arrow_downward", "ImageService.coreIcon('home')"),
        (r"Icons\.arrow_upward", "ImageService.coreIcon('home')"),
        (r"Icons\.refresh", "ImageService.coreIcon('more_menu')"),
    ]
    
    for old, new in replacements:
        content = re.sub(old, new, content)
    
    return content

def fix_subscriptions_screen(content):
    """إصلاح subscriptions_screen.dart"""
    replacements = [
        (r"Icons\.subscriptions", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.check_circle", "ImageService.coreIcon('home')"),
        (r"Icons\.arrow_forward_ios", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.credit_card", "ImageService.coreIcon('pharmacy')"),
        (r"Icons\.security", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.lock_outline", "ImageService.coreIcon('home')"),
    ]
    
    for old, new in replacements:
        content = re.sub(old, new, content)
    
    return content

def fix_settings_screen(content):
    """إصلاح settings_screen.dart"""
    replacements = [
        (r"Icons\.settings", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.dark_mode", "ImageService.coreIcon('home')"),
        (r"Icons\.brightness_auto", "ImageService.coreIcon('home')"),
        (r"Icons\.language", "ImageService.coreIcon('home')"),
        (r"Icons\.person", "ImageService.coreIcon('doctor')"),
        (r"Icons\.lock", "ImageService.coreIcon('home')"),
        (r"Icons\.notifications", "ImageService.coreIcon('notifications_active')"),
        (r"Icons\.help", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.feedback", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.share", "ImageService.socialIcon('whatsapp')"),
        (r"Icons\.logout", "ImageService.coreIcon('home')"),
        (r"Icons\.arrow_forward_ios", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.health_and_safety", "ImageService.coreIcon('home')"),
        (r"Icons\.restore", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.remove_circle_outline", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.add_circle_outline", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.text_decrease", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.text_increase", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.text_fields", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.privacy_tip", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.assignment", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.contact_support", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.report", "ImageService.coreIcon('more_menu')"),
        (r"Icons\.download", "ImageService.coreIcon('more_menu')"),
    ]
    
    for old, new in replacements:
        content = re.sub(old, new, content)
    
    return content

def main():
    print("🔧 بدء إصلاح الملفات...")
    print("═══════════════════════════════════════════════════════════════════")
    
    for file_path in FILES_TO_FIX:
        if not os.path.exists(file_path):
            print(f"⚠️  {file_path} - غير موجود")
            continue
        
        print(f"📄 إصلاح: {file_path}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # إضافة import
        content = add_import(file_path)
        
        # تطبيق الإصلاحات حسب الملف
        if 'more_screen.dart' in file_path:
            content = fix_more_screen(content)
        elif 'chat_screen.dart' in file_path:
            content = fix_chat_screen(content)
        elif 'wallet_screen.dart' in file_path:
            content = fix_wallet_screen(content)
        elif 'subscriptions_screen.dart' in file_path:
            content = fix_subscriptions_screen(content)
        elif 'settings_screen.dart' in file_path:
            content = fix_settings_screen(content)
        
        # حفظ الملف
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"   ✅ تم الإصلاح")
    
    print("═══════════════════════════════════════════════════════════════════")
    print("✅ تم إصلاح جميع الملفات بنجاح!")

if __name__ == "__main__":
    main()
