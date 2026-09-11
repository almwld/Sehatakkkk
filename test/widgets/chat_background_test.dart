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

    // The test host can contain another Stack (for example from MaterialApp
    // internals). Scope the assertion to ChatBackground itself so the test
    // verifies the widget we own rather than assuming Stack is globally unique.
    final background = find.byType(ChatBackground);
    expect(background, findsOneWidget);
    expect(
      find.descendant(of: background, matching: find.byType(Stack)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: background, matching: find.byType(IgnorePointer)),
      findsOneWidget,
    );
  });
}
