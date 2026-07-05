import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State
class ThemeState {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});
}

// Events
abstract class ThemeEvent {}
class SetLightTheme extends ThemeEvent {}
class SetDarkTheme extends ThemeEvent {}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.light)) {
    on<SetLightTheme>((event, emit) {
      emit(const ThemeState(themeMode: ThemeMode.light));
    });
    on<SetDarkTheme>((event, emit) {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    });
  }
}
