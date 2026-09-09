import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/bloc/home/home_repository_fixed.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepositoryFixed _repository;
  HomeBloc({HomeRepositoryFixed? repository}) : _repository = repository ?? HomeRepositoryFixed(), super(const HomeState()) {
    on<HomeStarted>(_onStarted); on<HomeDataFetched>(_onDataFetched); on<HomeDataRefreshed>(_onDataRefreshed); on<HomeBannerChanged>(_onBannerChanged);
  }
  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async { if (state.isLoading || state.isLoaded) return; await _fetchAllData(emit, initialLoad: true); }
  Future<void> _onDataFetched(HomeDataFetched event, Emitter<HomeState> emit) async { if (state.isLoaded || state.isLoading) return; await _fetchAllData(emit, initialLoad: true); }
  Future<void> _onDataRefreshed(HomeDataRefreshed event, Emitter<HomeState> emit) async { if (state.isRefreshing) return; await _fetchAllData(emit, initialLoad: false); }
  void _onBannerChanged(HomeBannerChanged event, Emitter<HomeState> emit) => emit(state.copyWith(currentBanner: event.index));

  Future<void> _fetchAllData(Emitter<HomeState> emit, {required bool initialLoad}) async {
    emit(state.copyWith(status: initialLoad ? HomeStatus.loading : HomeStatus.refreshing, errorMessage: null, bannerImages: ImageKit.bannerList));
    final user = await _safe(() => _repository.getUserData(), (isLoggedIn: false, userName: 'مستخدم'));
    final stats = await _safe(() => _repository.getHealthStats(), (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0));
    final doctors = await _safe(() => _repository.getDoctors(), <Map<String,dynamic>>[]);
    final hospitals = await _safe(() => _repository.getHospitals(), <Map<String,dynamic>>[]);
    final pharmacies = await _safe(() => _repository.getPharmacies(), <Map<String,dynamic>>[]);
    final labs = await _safe(() => _repository.getLabs(), <Map<String,dynamic>>[]);
    final articles = await _safe(() => _repository.getArticles(), <Map<String,dynamic>>[]);
    final tips = await _safe(() => _repository.getTips(), <Map<String,dynamic>>[]);
    final posts = await _safe(() => _repository.getCommunityPosts(), <Map<String,dynamic>>[]);
    final notifications = await _safe(() => _repository.getNotificationCount(), 0);
    emit(state.copyWith(status: HomeStatus.loaded, isLoggedIn: user.isLoggedIn, userName: user.userName, bannerImages: ImageKit.bannerList, calories: stats.calories, steps: stats.steps, sleep: stats.sleep, heartRate: stats.heartRate, doctors: doctors, hospitals: hospitals, pharmacies: pharmacies, labs: labs, articles: articles, tips: tips, communityPosts: posts, notificationCount: notifications));
  }
  Future<T> _safe<T>(Future<T> Function() action, T fallback) async { try { return await action(); } catch (_) { return fallback; } }
}
