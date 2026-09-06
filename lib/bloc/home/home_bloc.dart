import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/bloc/home/home_repository.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc({
    HomeRepository? repository,
  })  : _repository = repository ?? HomeRepository(),
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeDataFetched>(_onDataFetched);
    on<HomeDataRefreshed>(_onDataRefreshed);
    on<HomeBannerChanged>(_onBannerChanged);
  }

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isLoading || state.isLoaded) {
      return;
    }

    await _fetchAllData(
      emit,
      initialLoad: true,
    );
  }

  Future<void> _onDataFetched(
    HomeDataFetched event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isLoaded || state.isLoading) {
      return;
    }

    await _fetchAllData(
      emit,
      initialLoad: true,
    );
  }

  Future<void> _onDataRefreshed(
    HomeDataRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isRefreshing) {
      return;
    }

    await _fetchAllData(
      emit,
      initialLoad: false,
    );
  }

  void _onBannerChanged(
    HomeBannerChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        currentBanner: event.index,
      ),
    );
  }

  Future<void> _fetchAllData(
    Emitter<HomeState> emit, {
    required bool initialLoad,
  }) async {
    emit(
      state.copyWith(
        status: initialLoad
            ? HomeStatus.loading
            : HomeStatus.refreshing,
        errorMessage: null,
        bannerImages: ImageKit.bannerList,
      ),
    );

    /*
     * كل مصدر يعمل بشكل مستقل.
     *
     * فشل الأطباء لا يسقط المجتمع.
     * فشل المجتمع لا يسقط البانر.
     * فشل Firebase لا يمسح الهيكل الأساسي للصفحة.
     */

    final userData = await _safe(
      () => _repository.getUserData(),
      (
        isLoggedIn: false,
        userName: 'مستخدم',
      ),
    );

    final healthStats = await _safe(
      () => _repository.getHealthStats(),
      (
        calories: 0.0,
        steps: 0.0,
        sleep: 0.0,
        heartRate: 0.0,
      ),
    );

    final doctors = await _safe(
      () => _repository.getDoctors(),
      <Map<String, dynamic>>[],
    );

    final hospitals = await _safe(
      () => _repository.getHospitals(),
      <Map<String, dynamic>>[],
    );

    final pharmacies = await _safe(
      () => _repository.getPharmacies(),
      <Map<String, dynamic>>[],
    );

    final labs = await _safe(
      () => _repository.getLabs(),
      <Map<String, dynamic>>[],
    );

    final articles = await _safe(
      () => _repository.getArticles(),
      <Map<String, dynamic>>[],
    );

    final tips = await _safe(
      () => _repository.getTips(),
      <Map<String, dynamic>>[],
    );

    final communityPosts = await _safe(
      () => _repository.getCommunityPosts(),
      <Map<String, dynamic>>[],
    );

    final notificationCount = await _safe(
      () => _repository.getNotificationCount(),
      0,
    );

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        isLoggedIn: userData.isLoggedIn,
        userName: userData.userName,
        bannerImages: ImageKit.bannerList,
        calories: healthStats.calories,
        steps: healthStats.steps,
        sleep: healthStats.sleep,
        heartRate: healthStats.heartRate,
        doctors: doctors,
        hospitals: hospitals,
        pharmacies: pharmacies,
        labs: labs,
        articles: articles,
        tips: tips,
        communityPosts: communityPosts,
        notificationCount: notificationCount,
      ),
    );
  }

  Future<T> _safe<T>(
    Future<T> Function() action,
    T fallback,
  ) async {
    try {
      return await action();
    } catch (e) {
      return fallback;
    }
  }
}
