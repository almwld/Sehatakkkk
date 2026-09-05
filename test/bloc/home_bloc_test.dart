// ============================================================
// 📁 test/bloc/home_bloc_test.dart
// 🧪 اختبارات Home Bloc
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';

void main() {
  group('HomeBloc', () {
    late HomeBloc homeBloc;

    setUp(() {
      homeBloc = HomeBloc();
    });

    tearDown(() {
      homeBloc.close();
    });

    test('initial state is correct', () {
      expect(homeBloc.state, const HomeState());
    });

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when HomeStarted is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loaded),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeRefreshing, HomeLoaded] when HomeDataRefreshed is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeDataRefreshed()),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.refreshing),
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loaded),
      ],
    );
  });
}
