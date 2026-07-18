import 'package:flutter/material.dart';

mixin BottomBarVisibilityMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController;
  late final ValueNotifier<bool> isBottomBarVisible;

  void initBottomBarVisibility(ValueNotifier<bool> parentNotifier) {
    isBottomBarVisible = parentNotifier;
    scrollController = ScrollController();

    scrollController.addListener(() {
      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
      if (homeState == null) return;

      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (homeState._isBottomBarVisible.value != false) {
          homeState._isBottomBarVisible.value = false;
        }
      } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (homeState._isBottomBarVisible.value != true) {
          homeState._isBottomBarVisible.value = true;
        }
      }
    });
  }

  void disposeBottomBarVisibility() {
    scrollController.dispose();
  }
}
