import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================
// 📦 States
// ============================================================
class ThemeState {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});
}

// ============================================================
// 📦 Events
// ============================================================
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}
class SetLightTheme extends ThemeEvent {}
class SetDarkTheme extends ThemeEvent {}
class SetSystemTheme extends ThemeEvent {}

// ============================================================
// 🧠 BLoC
// ============================================================
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<ToggleTheme>(_onToggleTheme);
    on<SetLightTheme>(_onSetLightTheme);
    on<SetDarkTheme>(_onSetDarkTheme);
    on<SetSystemTheme>(_onSetSystemTheme);
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    if (state.themeMode == ThemeMode.light) {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else {
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  void _onSetLightTheme(SetLightTheme event, Emitter<ThemeState> emit) {
    emit(const ThemeState(themeMode: ThemeMode.light));
  }

  void _onSetDarkTheme(SetDarkTheme event, Emitter<ThemeState> emit) {
    emit(const ThemeState(themeMode: ThemeMode.dark));
  }

  void _onSetSystemTheme(SetSystemTheme event, Emitter<ThemeState> emit) {
    emit(const ThemeState(themeMode: ThemeMode.system));
  }
}
