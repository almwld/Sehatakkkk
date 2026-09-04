import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  factory ThemeState.initial() => const ThemeState(themeMode: ThemeMode.system);
}

class ThemeBloc extends Cubit<ThemeState> {
  ThemeBloc() : super(ThemeState.initial());

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(themeMode: newMode));
  }

  void setThemeMode(ThemeMode mode) {
    emit(ThemeState(themeMode: mode));
  }
}
