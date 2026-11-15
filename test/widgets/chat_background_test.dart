// ============================================================
// ChatBackground widget tests
// ============================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';

const _testWallpaper = '''
<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">
  <rect width="10" height="10" fill="#ffffff"/>
</svg>
''';

class _WallpaperAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.view(Uint8List.fromList(utf8.encode(_testWallpaper)).buffer);
  }
}

Widget _testApp(Widget child) {
  return DefaultAssetBundle(
    bundle: _WallpaperAssetBundle(),
    child: MaterialApp(
      home: Scaffold(body: ChatBackground(child: child)),
    ),
  );
}

void main() {
  testWidgets('ChatBackground renders child correctly', (tester) async {
    await tester.pumpWidget(_testApp(const Text('Test Child')));
    await tester.pump();

    expect(find.text('Test Child'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChatBackground renders wallpaper layer', (tester) async {
    await tester.pumpWidget(_testApp(const SizedBox.shrink()));
    await tester.pump();

    // Scope assertions to ChatBackground rather than MaterialApp internals.
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
    expect(tester.takeException(), isNull);
  });
}
