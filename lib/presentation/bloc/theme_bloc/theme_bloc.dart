import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class SetDarkTheme extends ThemeEvent {}
class SetLightTheme extends ThemeEvent {}
class ToggleTheme extends ThemeEvent {}

// States
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});
  
  factory ThemeState.initial() => const ThemeState(themeMode: ThemeMode.system);
  
  @override
  List<Object?> get props => [themeMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<SetDarkTheme>((event, emit) => emit(ThemeState(themeMode: ThemeMode.dark)));
    on<SetLightTheme>((event, emit) => emit(ThemeState(themeMode: ThemeMode.light)));
    on<ToggleTheme>((event, emit) {
      if (state.themeMode == ThemeMode.dark) {
        emit(ThemeState(themeMode: ThemeMode.light));
      } else {
        emit(ThemeState(themeMode: ThemeMode.dark));
      }
    });
  }
}
