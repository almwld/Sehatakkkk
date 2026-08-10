import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/data/repositories/home_data_repository.dart';
import 'package:sehatak/data/models/doctor_model.dart';
import 'package:sehatak/data/models/product_model.dart';
import 'package:sehatak/data/models/hospital_model.dart';
import 'package:sehatak/data/models/lab_model.dart';
import 'package:sehatak/data/models/pharmacy_model.dart';
import 'package:sehatak/data/models/article_model.dart';
import 'package:sehatak/data/models/community_post_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) {
    try {
      final doctors = HomeDataRepository.getTopDoctors();
      final products = HomeDataRepository.getProducts();
      final hospitals = HomeDataRepository.getFeaturedHospitals();
      final labs = HomeDataRepository.getFeaturedLabs();
      final pharmacies = HomeDataRepository.getFeaturedPharmacies();
      final articles = HomeDataRepository.getArticles();
      final posts = HomeDataRepository.getCommunityPosts();

      emit(HomeState(
        isLoading: false,
        hasError: false,
        doctors: doctors,
        products: products,
        hospitals: hospitals,
        labs: labs,
        pharmacies: pharmacies,
        articles: articles,
        posts: posts,
        healthScore: 75.0,
      ));
    } catch (_) {
      emit(const HomeState(isLoading: false, hasError: true));
    }
  }

  void _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) {
    try {
      final doctors = HomeDataRepository.getTopDoctors();
      final products = HomeDataRepository.getProducts();

      emit(HomeState(
        isRefreshing: false,
        doctors: doctors,
        products: products,
      ));
    } catch (_) {
      emit(const HomeState(isRefreshing: false, hasError: true));
    }
  }
}
