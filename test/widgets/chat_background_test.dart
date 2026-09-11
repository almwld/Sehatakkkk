// ============================================================
// 📁 test/widgets/chat_background_test.dart
// 🧪 اختبارات Chat Background Widget
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';

void main() {
  testWidgets('ChatBackground renders child correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatBackground(
            child: Text('Test Child'),
          ),
        ),
      ),
    );

    expect(find.text('Test Child'), findsOneWidget);
  });

  testWidgets('ChatBackground renders wallpaper layer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatBackground(
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    // ChatBackground now uses a Stack + IgnorePointer wallpaper layer
    // instead of a Container decoration.
    expect(find.byType(Stack), findsOneWidget);
    expect(find.byType(IgnorePointer), findsOneWidget);
  });
}
