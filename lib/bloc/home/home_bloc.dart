// ============================================================
// 📁 lib/bloc/home/home_bloc.dart
// 🧠 منطق Home
// ============================================================

import 'package:bloc/bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/bloc/home/home_repository.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository = HomeRepository();

  HomeBloc() : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeDataFetched>(_onDataFetched);
    on<HomeDataRefreshed>(_onDataRefreshed);
    on<HomeBannerChanged>(_onBannerChanged);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    await _fetchAllData(emit);
  }

  Future<void> _onDataFetched(HomeDataFetched event, Emitter<HomeState> emit) async {
    if (state.isLoaded) return;
    emit(state.copyWith(status: HomeStatus.loading));
    await _fetchAllData(emit);
  }

  Future<void> _onDataRefreshed(HomeDataRefreshed event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.refreshing));
    await _fetchAllData(emit);
  }

  void _onBannerChanged(HomeBannerChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(currentBanner: event.index));
  }

  Future<void> _fetchAllData(Emitter<HomeState> emit) async {
    try {
      final results = await Future.wait([
        _repository.getUserData(),
        _repository.getHealthStats(),
        _repository.getDoctors(),
        _repository.getHospitals(),
        _repository.getPharmacies(),
        _repository.getLabs(),
        _repository.getArticles(),
        _repository.getTips(),
        _repository.getCommunityPosts(),
        _repository.getNotificationCount(),
      ]);

      final userData = results[0] as ({bool isLoggedIn, String userName});
      final healthStats = results[1] as ({double calories, double steps, double sleep, double heartRate});
      final doctors = results[2] as List<DoctorModel>;
      final hospitals = results[3] as List<HospitalModel>;
      final pharmacies = results[4] as List<PharmacyModel>;
      final labs = results[5] as List<LabModel>;
      final articles = results[6] as List<ArticleModel>;
      final tips = results[7] as List<TipModel>;
      final communityPosts = results[8] as List<CommunityPostModel>;
      final notificationCount = results[9] as int;

      emit(state.copyWith(
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
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'حدث خطأ في تحميل البيانات: $e',
      ));
    }
  }
}
