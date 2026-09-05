// ============================================================
// 📁 lib/bloc/home/home_event.dart
// 🎯 أحداث Home
// ============================================================

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {}
class HomeDataFetched extends HomeEvent {}
class HomeDataRefreshed extends HomeEvent {}
class HomeBannerChanged extends HomeEvent {
  final int index;
  const HomeBannerChanged({required this.index});
  @override
  List<Object?> get props => [index];
}
